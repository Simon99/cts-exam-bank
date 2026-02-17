# Q008 Answer: SELinux Neverallow Rules Parser

## 正確答案
**A) LINE A 的 `substring(0)` 應該是 `substring(1)`，目前沒有移除 `-` 前綴，導致排除列表存放的是 `-init` 而非 `init`**

## 問題根因

### Bug 位置: NeverallowRuleParser.java LINE A
```java
if (token.charAt(0) == EXCLUSION_PREFIX) {
    String excluded = token.substring(0);  // BUG: 這只是複製整個字串
    rule.excludedDomains.add(excluded);
}
```

### 問題分析
`String.substring(0)` 返回從 index 0 開始到結尾的子字串，等於複製整個字串。當 token 是 `-init` 時：
- `token.substring(0)` 返回 `-init`（完整字串）
- `token.substring(1)` 才會返回 `init`（移除第一個字元）

### 錯誤流程
1. 規則字串：`"{ domain -init -kernel }"`
2. 解析後 tokens：`["domain", "-init", "-kernel"]`
3. 處理 `-init`：
   - `token.charAt(0) == '-'` ✓ 識別為例外
   - `token.substring(0)` 返回 `-init` ✗ 應該是 `init`
4. `excludedDomains` 存放 `["-init", "-kernel"]` 而非 `["init", "kernel"]`
5. 檢查 `isDomainAllowed("init", rule)` 時：
   - `excludedDomains.contains("init")` 返回 `false`（因為集合中是 `-init`）
   - `init` domain 被誤判為需要檢查的對象
6. CTS 報告 `init` domain 違規

## 修復方式
```java
// 錯誤
String excluded = token.substring(0);

// 正確
String excluded = token.substring(1);  // 從 index 1 開始，跳過 '-' 前綴
```

## 選項分析

- **A) 正確** - `substring(0)` vs `substring(1)` 是典型的 off-by-one 錯誤，開發者可能誤以為 `substring(0)` 會跳過第 0 個字元

- **B) 錯誤** - 這是一種 workaround，但違反設計意圖。排除列表應該存放乾淨的 domain 名稱，而非帶前綴的格式。修改 LINE B 會隱藏 LINE A 的 bug，且讓程式碼更難維護

- **C) 錯誤** - `split("\\s+")` 會正確處理連續空白，即使產生空字串，後續的 `if (token.isEmpty()) continue;` 也會跳過

- **D) 錯誤** - `char` 和 `String` 在這個上下文沒有影響。`token.charAt(0) == EXCLUSION_PREFIX` 是 char-to-char 比較，完全合法

## 為什麼是 Hard 難度

1. **隱蔽的 API 誤用** - `substring(0)` 看起來像是「從頭開始」，但實際上等於無操作
2. **跨方法追蹤** - 需要從 `parseSourceDomains()` 追蹤到 `isDomainAllowed()` 才能理解完整影響
3. **SELinux 策略知識** - 需要理解 neverallow 規則的語義和例外機制
4. **迷惑選項** - 選項 B 提供了一個「修正」方案，但實際上是在錯誤的地方打補丁

## 延伸知識

### String.substring() 行為
```java
String s = "-init";
s.substring(0)   // "-init" (從 index 0 到結尾)
s.substring(1)   // "init"  (從 index 1 到結尾)
s.substring(0,1) // "-"     (從 index 0 到 1，不含 1)
```

### SELinux Neverallow 規則
- 用於定義永遠不應該被允許的權限
- 在 Android 中用於強化安全策略
- 違規表示設備策略與基準不符，可能存在安全風險

## Bug 類型
- **Off-by-one error** - 索引計算錯誤
- **API misunderstanding** - 誤解 substring() 的參數含義

## 相關 CTS 測試
```bash
# 執行 SELinux Host-side 測試
run cts -m CtsSecurityHostTestCases -t SELinuxNeverallowRulesTest
```
