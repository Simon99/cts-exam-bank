# Q006: SELinux Neverallow Rule Parsing Error

## CTS Test
`android.security.cts.SELinuxNeverallowRulesTest#testNeverallowRules`

## Failure Log
```
junit.framework.AssertionFailedError: The following errors were encountered when validating the SELinux neverallow rule:
neverallow domain{ system_data_file }:file { write };

sepolicy-analyze: neverallow rule syntax error: unexpected '{'
    at android.security.cts.SELinuxNeverallowRulesTest.testNeverallowRules(SELinuxNeverallowRulesTest.java:285)
```

## 現象描述
CTS 測試在驗證 SELinux neverallow 規則時失敗。錯誤訊息顯示規則語法錯誤，特別是在 `domain` 和 `{` 之間缺少空格。但檢查原始的 policy 檔案（general_sepolicy.conf），規則格式是正確的，每行之間有適當的分隔。

原始 policy 檔案中的規則（跨多行）：
```
neverallow domain
    { system_data_file }:file { write };
```

## 背景知識
SELinux neverallow 規則定義了絕對禁止的權限組合。CTS 測試需要從嵌入的 policy 檔案中解析這些規則，然後傳給 `sepolicy-analyze` 工具驗證設備策略。

- **多行規則** - Policy 檔案中的規則可能跨多行以提高可讀性
- **空白處理** - 規則解析時需要正確處理換行符和空格
- **正則匹配** - 使用 Pattern 匹配 `neverallow` 規則直到分號

## 提示
- 問題涉及多行規則的字串處理
- 注意 `replace()` 方法的行為
- 思考換行符替換對語法的影響

## 問題
根據以下程式碼片段，哪個問題最可能導致此 CTS 失敗？

**檔案: SELinuxNeverallowRulesTest.java**
```java
public class SELinuxNeverallowRulesTest extends BaseHostJUnit4Test {
    
    public static ArrayList<NeverAllowRule> parsePolicy(String policy) throws Exception {
        // ... 前處理省略 ...
        
        /* Use a pattern to match all the neverallow rules or a condition. */
        Pattern neverAllowPattern = Pattern.compile(
                "(neverallow\\s[^;]+?;|" + patternConditions + ")",
                Pattern.MULTILINE);

        ArrayList<NeverAllowRule> rules = new ArrayList();
        HashMap<String, Integer> conditions = new HashMap();

        matcher = neverAllowPattern.matcher(policy);
        while (matcher.find()) {
            String rule = matcher.group(1).replace("\n", "");  // LINE A
            if (rule.startsWith("BEGIN_")) {
                String section = rule.substring(6);
                conditions.put(section, conditions.getOrDefault(section, 0) + 1);
            } else if (rule.startsWith("END_")) {
                String section = rule.substring(4);
                Integer v = conditions.getOrDefault(section, 0);
                assertTrue("Condition " + rule + " found without BEGIN", v > 0);
                conditions.put(section, v - 1);
            } else if (rule.startsWith("neverallow")) {  // LINE B
                rules.add(new NeverAllowRule(rule, conditions));
            } else {
                throw new Exception("Unknown rule: " + rule);  // LINE C
            }
        }
        return rules;
    }
    
    @Test
    public void testNeverallowRules() throws Exception {
        // ... 條件檢查省略 ...
        
        /* run sepolicy-analyze neverallow check on policy file */
        ProcessBuilder pb = new ProcessBuilder(sepolicyAnalyze.getAbsolutePath(),
                policyFile.getAbsolutePath(), "neverallow", "-n",
                mRule.mText);  // LINE D - 傳入解析後的規則文本
        // ...
        assertTrue("The following errors were encountered when validating the SELinux"
                   + "neverallow rule:\n" + mRule.mText + "\n" + errorString,
                   errorString.length() == 0);  // LINE E
    }
}
```

**Policy 檔案範例**（general_sepolicy.conf）：
```
neverallow domain
    { system_data_file }:file { write };

neverallow untrusted_app
    { system_file }:file { execute };
```

A) LINE A 字串處理錯誤：`.replace("\n", "")` 直接移除換行符而非替換為空格，導致多行規則的關鍵字和 token 之間缺少分隔符
B) LINE B 邏輯錯誤：`startsWith("neverallow")` 無法匹配因換行導致的格式變化
C) LINE C 異常處理錯誤：對於無法識別的規則應該忽略而非拋出異常
D) LINE D 參數傳遞錯誤：`mRule.mText` 應該先經過 escape 處理才能傳給 ProcessBuilder
E) LINE E 驗證條件錯誤：應該檢查 exit code 而非 errorString 長度
