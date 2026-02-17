# Q008: 答案與解析

## 正確答案
**A) `keyCodeFromString()` 中使用 `endsWith()` 而非 `startsWith()` 判斷前綴**

## 解析

### Bug 位置
`frameworks/base/core/java/android/view/KeyEvent.java` 第 3184 行

### 錯誤代碼
```java
if (symbolicName.endsWith(LABEL_PREFIX)) {
    symbolicName = symbolicName.substring(LABEL_PREFIX.length());
}
```

### 正確代碼
```java
if (symbolicName.startsWith(LABEL_PREFIX)) {
    symbolicName = symbolicName.substring(LABEL_PREFIX.length());
}
```

### 問題分析
`LABEL_PREFIX` 定義為 `"KEYCODE_"`。當輸入是 `"KEYCODE_A"` 時：
- **錯誤邏輯**：`"KEYCODE_A".endsWith("KEYCODE_")` 為 `false`，不會進入 if 區塊
- **正確邏輯**：`"KEYCODE_A".startsWith("KEYCODE_")` 為 `true`，會移除前綴

因為 `endsWith()` 判斷失敗，前綴 `"KEYCODE_"` 沒有被移除，導致傳給 `nativeKeyCodeFromString()` 的是完整的 `"KEYCODE_A"` 而非 `"A"`。native 方法無法識別帶前綴的名稱，最終回傳 `KEYCODE_UNKNOWN`。

### 選項分析
- **B) substring 切割長度錯誤**：substring 使用 `LABEL_PREFIX.length()` 是正確的，問題不在切割邏輯
- **C) LABEL_PREFIX 常數定義錯誤**：常數定義為 `"KEYCODE_"` 是正確的
- **D) 少了 toLowerCase()**：按鍵碼名稱本來就是大寫，不需要轉換
