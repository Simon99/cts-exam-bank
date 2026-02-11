# Q006: SELinux Neverallow Rule Parsing Error - 答案解析

## 正確答案：A

## 解析

### 問題核心
LINE A 的 `.replace("\n", "")` 直接移除換行符而非替換為空格，導致多行 neverallow 規則合併時關鍵字和 token 之間缺少分隔符。

### 錯誤代碼分析

**Bug 所在：**
```java
String rule = matcher.group(1).replace("\n", "");  // 錯誤！
```

**應該是：**
```java
String rule = matcher.group(1).replace("\n", " ");  // 用空格替換換行
```

### 影響過程

1. **原始 Policy 檔案**（多行格式）：
   ```
   neverallow domain
       { system_data_file }:file { write };
   ```

2. **正確處理**（用空格替換換行）：
   ```
   neverallow domain { system_data_file }:file { write };
   ```

3. **錯誤處理**（直接移除換行）：
   ```
   neverallow domain{ system_data_file }:file { write };
   ```
   注意 `domain` 和 `{` 之間沒有空格！

4. **傳給 sepolicy-analyze**：
   工具收到格式錯誤的規則，報告語法錯誤。

### 為什麼這是 Hard 難度

1. **隱蔽性高** — 錯誤看起來只是空白處理的微小差異
2. **需要理解流程** — 從 policy 解析到工具調用的完整流程
3. **跨系統邊界** — 錯誤在 Java 端產生，在 native 工具端報告
4. **SELinux 知識** — 需理解 neverallow 語法對空白敏感

### 其他選項分析

**B) `startsWith("neverallow")` 無法匹配**
- 錯誤。正則表達式已確保匹配的規則以 `neverallow` 開頭。換行移除不影響開頭判斷。

**C) 異常處理應該忽略**
- 錯誤。對於無法識別的規則拋出異常是正確的防禦性程式設計，可以及早發現問題。

**D) 參數需要 escape**
- 錯誤。ProcessBuilder 直接傳遞參數，不需要額外 escape。Shell 注入風險不適用於此場景。

**E) 應檢查 exit code**
- 錯誤。檢查 errorString 長度是有效的驗證方式。sepolicy-analyze 將錯誤輸出到 stdout/stderr。

## 修復方式

將 LINE A 改為：
```java
String rule = matcher.group(1).replace("\n", " ");
```

## 知識點

1. **字串替換** — `replace()` 的替換值很重要，空字串和空格有本質差異
2. **SELinux 語法** — token 之間必須有空白分隔
3. **多行規則處理** — 解析器需要正確處理跨行的語法結構
4. **工具鏈整合** — CTS 使用 sepolicy-analyze 進行實際驗證

## 相關 CTS 測試

- `CtsSecurityHostTestCases`
- 參數化測試從 `general_sepolicy.conf` 動態生成測試案例
