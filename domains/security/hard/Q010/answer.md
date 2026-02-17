# Q010 Answer: SELinux Neverallow 規則解析與域屬性匹配

## 正確答案
**C) LINE N4 使用 `equals()` 比較 Set 與 String：應該用 `contains()` 檢查 domainAttrs 是否包含 violator 屬性**

## 問題根因
這道題的核心 bug 在 `isExcludedByViolator()` 方法中：

### Bug 分析: LINE N4
```java
if (domainAttrs.equals(attr)) {  // LINE N4 - BUG!
    return true;
}
```

這行程式碼嘗試檢查 domain 是否具有某個 violator 屬性，但錯誤地使用了 `Set.equals(String)`：

- `domainAttrs` 是 `Set<String>` 類型，包含該 domain 的所有屬性
- `attr` 是 `String` 類型，是一個 violator 屬性名稱
- `Set.equals(String)` 永遠返回 `false`，因為 Set 不可能等於一個 String

### 正確寫法
```java
if (domainAttrs.contains(attr)) {  // 正確：檢查 Set 是否包含此屬性
    return true;
}
```

### 錯誤影響
1. `isExcludedByViolator()` 永遠返回 `false`
2. `vold` 雖然具有 `data_between_core_and_vendor_violators` 屬性
3. 但此屬性無法被正確識別
4. `vold` 被錯誤地視為違規

## 選項分析

### A) 錯誤 - LINE N1 空字串問題
```java
exclusions.add(part.substring(1));
```
雖然理論上 `"-".substring(1)` 會產生空字串，但：
- SELinux 規則語法不允許單獨的 `-`
- 即使產生空字串，後續 `isAttribute("")` 會返回 `false`
- 這不會造成 "violator 未被識別" 的錯誤現象

### B) 錯誤 - N2/N3 順序問題
排除處理的順序（先屬性後具體 domain 或反之）不影響最終結果：
- Set 的 `removeAll()` 和 `remove()` 操作是冪等的
- 順序不同只影響中間狀態，不影響最終集合
- 題目的錯誤是 "violator 屬性未生效"，與排除順序無關

### C) 正確 - 類型錯誤
這是經典的類型混淆 bug：
- 開發者意圖檢查 Set 是否包含某元素
- 卻錯誤地使用 `equals()` 嘗試比較整個集合
- Java 編譯器不會報錯（`Object.equals()` 接受任何類型）
- 運行時不會拋異常，只是永遠返回 `false`

### D) 錯誤 - 設計問題
題目程式碼已經有 `isExcludedByViolator()` 機制處理 violator 屬性。問題不在於缺少此機制，而是實作有 bug。

## Bug 位置
- `cts/hostsidetests/security/src/android/security/cts/SELinuxNeverallowRulesTest.java`

## 修復方式
```java
// 錯誤
if (domainAttrs.equals(attr)) {

// 正確
if (domainAttrs.contains(attr)) {
```

## 為什麼是 Hard 難度

1. **SELinux 知識要求** - 需要理解 neverallow 規則語法、屬性繼承、violator 機制
2. **隱蔽的類型錯誤** - `Set.equals(String)` 編譯通過，不拋異常，只是靜默失敗
3. **多層邏輯** - 需要追蹤 parseNeverallowSource → testNeverallowRules → isExcludedByViolator 的呼叫鏈
4. **錯誤訊息分析** - 需要從 "vold not excluded" 推導出 violator 檢查失敗

## 相關知識

### SELinux Neverallow 規則
- 定義在 `system/sepolicy/` 目錄
- 用於確保某些危險權限不會被授予特定 domain
- CTS 會驗證設備 policy 不違反這些規則

### Violator 屬性
- 某些 domain 因歷史原因需要打破 neverallow 規則
- 這些 domain 被標記為 `*_violators` 屬性
- CTS 測試應該識別並跳過這些合法例外

### Java 類型系統陷阱
- `Object.equals(Object)` 接受任何類型，不會編譯報錯
- `Set.equals(String)` 語義上無意義但語法合法
- 建議使用 IDE 的類型檢查或靜態分析工具捕捉此類問題

## 難度說明
**Hard** - 結合 SELinux policy 知識、Java 集合 API 細節、以及多層程式碼追蹤。錯誤非常隱蔽，需要仔細閱讀才能發現 `equals` vs `contains` 的差異。
