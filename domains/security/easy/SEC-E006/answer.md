# SEC-E006 Answer: NoAuthRequired 標記錯誤處理

## 正確答案
**A) `isNoAuthRequired()` 返回了 `!mNoAuthRequired` 而非 `mNoAuthRequired`**

## 問題根因
在 `AuthorizationList.java` 的 `isNoAuthRequired()` 方法中，
返回值被錯誤地取反，導致結果與預期相反。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
public boolean isNoAuthRequired() {
    return !mNoAuthRequired;  // BUG: 不該取反
}

// 正確的代碼
public boolean isNoAuthRequired() {
    return mNoAuthRequired;
}
```

## 為什麼其他選項不對

**B)** 如果解析時設為 false，問題會在解析階段，錯誤訊息可能會有不同的 stack trace。

**C)** 這個方法通常只是返回布林值，不涉及 `&&` 或 `||` 運算。

**D)** 如果 TAG 解析被跳過，mNoAuthRequired 會保持預設值 false，效果相同但原因不同。
       從簡單性判斷，取反是最可能的單一錯誤。

## 相關知識
- NoAuthRequired 表示密鑰使用不需要使用者認證
- 這對於系統級密鑰或背景操作很重要
- 布林值取反 (`!`) 是常見的邏輯錯誤

## 難度說明
**Easy** - 布林值取反是明顯的邏輯錯誤。
