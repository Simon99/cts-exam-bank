# Q010: SELinux Neverallow 規則解析與域屬性匹配

## CTS Test
`android.security.cts.SELinuxNeverallowRulesTest#testNeverallowRules`

## Failure Log
```
java.lang.AssertionError: Neverallow rule violation detected on device

Rule: neverallow { domain -init -kernel } self:capability { sys_rawio };

Violation context:
  Source domain: vold
  Target: self
  Class: capability
  Permission: sys_rawio
  
Policy analysis output:
  vold has attribute: domain ✓
  vold has attribute: init  ✗
  vold has attribute: kernel ✗
  Exclusion check result: NOT EXCLUDED
  Rule should apply to vold: YES
  
But vold legitimately needs sys_rawio for block device access and is properly
configured with: "allow vold self:capability sys_rawio;"
The test should have recognized vold's exception via attribute "data_between_core_and_vendor_violators"

at android.security.cts.SELinuxNeverallowRulesTest.testNeverallowRules(SELinuxNeverallowRulesTest.java:178)
```

## 現象描述
CTS Host-side 測試報告 SELinux neverallow 規則違規。`vold` domain 擁有 `sys_rawio` capability，這看起來違反了 neverallow 規則，但 `vold` 實際上是通過特殊屬性 `data_between_core_and_vendor_violators` 被合法排除的。測試未能正確解析多層屬性排除邏輯。

## 背景知識
SELinux neverallow 規則語法：
- `neverallow source target:class { permissions };`
- `{ domain -init -kernel }` 表示 "所有 domain 屬性的類型，排除 init 和 kernel"
- 減號 `-` 表示排除
- 屬性(attribute)可以嵌套，一個 domain 可能同時屬於多個屬性
- 某些 domain 通過特殊 violator 屬性被合法排除

## 提示
- 問題涉及 `SELinuxNeverallowRulesTest.java` 中的規則解析邏輯
- 注意屬性排除的處理方式：直接排除 vs 屬性繼承排除
- 考慮多層屬性的情況：domain 可能包含 violator 屬性成員
- 字串處理和集合操作可能導致微妙的 bug

## 問題
根據以下 `SELinuxNeverallowRulesTest.java` 的程式碼片段，哪個選項最可能導致此 CTS 失敗？

**檔案: SELinuxNeverallowRulesTest.java**
```java
public class SELinuxNeverallowRulesTest extends DeviceTestCase {
    
    private Set<String> mExcludedDomains;
    private Map<String, Set<String>> mDomainAttributes;  // domain -> its attributes
    private Set<String> mViolatorAttributes;  // 合法的 violator 屬性集合
    
    /**
     * 解析 neverallow 規則的 source 部分
     * 例如: "{ domain -init -kernel }" 
     * 返回: 應該受此規則約束的 domain 集合
     */
    private Set<String> parseNeverallowSource(String sourceSpec) {
        Set<String> result = new HashSet<>();
        Set<String> exclusions = new HashSet<>();
        
        // 移除括號並分割
        String content = sourceSpec.replaceAll("[{}]", "").trim();
        String[] parts = content.split("\\s+");
        
        for (String part : parts) {
            if (part.startsWith("-")) {
                // 排除項目
                exclusions.add(part.substring(1));  // LINE N1
            } else {
                // 包含項目（屬性或 domain）
                result.addAll(getDomainsWithAttribute(part));
            }
        }
        
        // 移除被排除的 domains
        for (String exclusion : exclusions) {
            if (isAttribute(exclusion)) {
                // 如果排除項是屬性，移除所有具有該屬性的 domains
                result.removeAll(getDomainsWithAttribute(exclusion));  // LINE N2
            } else {
                // 如果排除項是具體 domain，直接移除
                result.remove(exclusion);  // LINE N3
            }
        }
        
        return result;
    }
    
    /**
     * 檢查指定 domain 是否被 violator 屬性排除
     */
    private boolean isExcludedByViolator(String domain) {
        Set<String> domainAttrs = mDomainAttributes.get(domain);
        if (domainAttrs == null) {
            return false;
        }
        
        for (String attr : mViolatorAttributes) {
            if (domainAttrs.equals(attr)) {  // LINE N4
                return true;
            }
        }
        return false;
    }
    
    /**
     * 主測試邏輯
     */
    public void testNeverallowRules() throws Exception {
        List<NeverallowRule> rules = loadNeverallowRules();
        
        for (NeverallowRule rule : rules) {
            Set<String> sourceDomains = parseNeverallowSource(rule.getSource());
            
            for (String domain : sourceDomains) {
                // 先檢查是否被 violator 屬性排除
                if (isExcludedByViolator(domain)) {
                    continue;  // 合法排除，跳過
                }
                
                // 檢查此 domain 是否違規
                if (domainHasPermission(domain, rule.getTarget(), 
                        rule.getObjectClass(), rule.getPermissions())) {
                    fail("Neverallow violation: " + domain + " has " + 
                         rule.getPermissions() + " which is prohibited");
                }
            }
        }
    }
    
    private Set<String> getDomainsWithAttribute(String attribute) {
        // 返回所有具有指定屬性的 domains
        Set<String> result = new HashSet<>();
        for (Map.Entry<String, Set<String>> entry : mDomainAttributes.entrySet()) {
            if (entry.getValue().contains(attribute)) {
                result.add(entry.getKey());
            }
        }
        return result;
    }
    
    private boolean isAttribute(String name) {
        // 檢查名稱是否為已知屬性
        return mKnownAttributes.contains(name);
    }
}
```

A) LINE N1 移除減號時可能產生空字串：如果 part 只有 "-"，`substring(1)` 會返回空字串，導致後續查詢失敗

B) LINE N2 和 N3 的順序問題：應該先處理具體 domain 排除再處理屬性排除，否則屬性排除可能誤刪已保留的 domain

C) LINE N4 使用 `equals()` 比較 Set 與 String：應該用 `contains()` 檢查 domainAttrs 是否包含 violator 屬性

D) 問題在 `parseNeverallowSource()` 未處理 violator 屬性：屬性排除只看直接命名，沒有考慮 violator 屬性的間接排除機制

