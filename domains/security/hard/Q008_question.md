# Q008: SELinux Neverallow Rules Parser

## CTS Test
`android.security.cts.SELinuxNeverallowRulesTest#testNeverallowRulesEnforced`

## Failure Log
```
java.lang.AssertionError: SELinux neverallow rule violation detected

Rule parsing result:
  Input policy line: "neverallow { domain -init -kernel } self:capability { sys_rawio net_admin };"
  
Parsed rule:
  Source domains: [domain]
  Excluded domains: [-init, -kernel]
  Target: self
  Object class: capability
  Permissions: [sys_rawio, net_admin]
  
Validation failure:
  Expected excluded domains: [init, kernel]
  Actual excluded domains: [-init, -kernel]

Policy evaluation:
  Testing domain: init
  Should be excluded: true (due to "-init" in rule)
  Actually excluded: false <-- BUG
  
  Violation found: init domain has capability sys_rawio
  This should be allowed by the exception "-init" but was flagged as violation

at android.security.cts.SELinuxNeverallowRulesTest.testNeverallowRulesEnforced(SELinuxNeverallowRulesTest.java:312)
at android.security.cts.SELinuxHostTest.runNeverallowCheck(SELinuxHostTest.java:189)
```

## 現象描述
CTS Host-side 測試報告 SELinux neverallow 規則違規，但實際上 `init` domain 應該被 `-init` 例外排除。問題在於例外 domain 的解析沒有正確移除負號前綴，導致排除列表中存放的是 `-init` 而非 `init`，後續的排除檢查永遠失敗。

## 背景知識
SELinux neverallow 規則格式：
```
neverallow source_domains target:class permissions;
```

其中 `source_domains` 可以包含例外，使用 `-` 前綴表示排除：
- `{ domain -init -kernel }` 表示「所有 domain，但排除 init 和 kernel」
- 解析器需要識別 `-` 前綴並正確處理例外列表

## 提示
- 注意字串處理中 `substring()` 的參數
- 考慮如何從 `-init` 提取出 `init`
- 注意 `startsWith()` 回傳 true 後的處理邏輯

## 程式碼片段

**NeverallowRuleParser.java:**
```java
public class NeverallowRuleParser {
    private static final char EXCLUSION_PREFIX = '-';
    
    public static class ParsedRule {
        public Set<String> sourceDomains = new HashSet<>();
        public Set<String> excludedDomains = new HashSet<>();
        public String target;
        public String objectClass;
        public Set<String> permissions = new HashSet<>();
    }
    
    /**
     * Parse source domains block like "{ domain -init -kernel }"
     */
    public static void parseSourceDomains(String block, ParsedRule rule) {
        // Remove braces and trim
        String content = block.substring(1, block.length() - 1).trim();
        String[] tokens = content.split("\\s+");
        
        for (String token : tokens) {
            if (token.isEmpty()) continue;
            
            if (token.charAt(0) == EXCLUSION_PREFIX) {
                // Handle exclusion: "-init" should add "init" to excluded set
                String excluded = token.substring(0);  // LINE A
                rule.excludedDomains.add(excluded);
            } else {
                rule.sourceDomains.add(token);
            }
        }
    }
    
    /**
     * Check if a domain is allowed by this rule (not in source or excluded)
     */
    public static boolean isDomainAllowed(String domain, ParsedRule rule) {
        // If domain is in exclusion list, it's allowed (exception to the rule)
        if (rule.excludedDomains.contains(domain)) {  // LINE B
            return true;
        }
        // If domain matches source domains, it's subject to the rule
        return !rule.sourceDomains.contains(domain);
    }
}
```

**SELinuxNeverallowChecker.java:**
```java
public class SELinuxNeverallowChecker {
    private final List<ParsedRule> mRules;
    
    public List<String> checkViolations(Map<String, Set<String>> domainCapabilities) {
        List<String> violations = new ArrayList<>();
        
        for (ParsedRule rule : mRules) {
            for (Map.Entry<String, Set<String>> entry : domainCapabilities.entrySet()) {
                String domain = entry.getKey();
                Set<String> caps = entry.getValue();
                
                if (!NeverallowRuleParser.isDomainAllowed(domain, rule)) {
                    // Check if this domain has any of the forbidden permissions
                    for (String perm : rule.permissions) {
                        if (caps.contains(perm)) {
                            violations.add(String.format(
                                "Domain '%s' has forbidden %s:%s",
                                domain, rule.objectClass, perm));
                        }
                    }
                }
            }
        }
        return violations;
    }
}
```

## 選項

A) LINE A 的 `substring(0)` 應該是 `substring(1)`，目前沒有移除 `-` 前綴，導致排除列表存放的是 `-init` 而非 `init`

B) LINE B 的 `contains(domain)` 應該改為 `contains("-" + domain)`，因為排除列表存放的格式包含負號前綴

C) 問題在於 `split("\\s+")` 無法正確處理 `{` 後緊跟空白的情況，導致第一個 token 是空字串

D) `EXCLUSION_PREFIX` 應該宣告為 `String` 型別 "-" 而非 `char` 型別 '-'，才能正確用於字串比較
