# Q006 Answer: No Auth Required Flag

## 正確答案
**B) LINE A 和 LINE B 的返回值應該對調**

## 問題根因
`isNoAuthRequired()` 的邏輯完全顛倒了。在 KeyMaster 中，`TAG_NO_AUTH_REQUIRED` 
是一個布林標籤，它的**存在**表示不需要認證（true），**不存在**表示需要認證（false）。

但代碼將這個邏輯反過來了：tag 存在時返回 false，不存在時返回 true。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
public boolean isNoAuthRequired() {
    ASN1Primitive tag = findTag(TAG_NO_AUTH_REQUIRED);
    if (tag == null) {
        return true;   // BUG: 應該是 false
    }
    return false;      // BUG: 應該是 true
}

// 正確的代碼
public boolean isNoAuthRequired() {
    ASN1Primitive tag = findTag(TAG_NO_AUTH_REQUIRED);
    if (tag == null) {
        return false;  // TAG 不存在 = 需要認證
    }
    return true;       // TAG 存在 = 不需要認證
}
```

## 選項分析
- **A) 錯誤** - TAG 常數值在此情境下不是問題
- **B) 正確** - 返回值邏輯完全顛倒
- **C) 錯誤** - 布林標籤只需要檢查存在性，不需要解析內容
- **D) 錯誤** - null 是有效狀態，表示需要認證

## 相關知識
- KeyMaster 布林標籤：存在即為 true，不存在即為 false
- 類似標籤：NO_AUTH_REQUIRED, CALLER_NONCE, TRUSTED_CONFIRMATION_REQUIRED
- 這是一種節省空間的設計，避免在授權列表中存儲 false 值

## 難度說明
**Easy** - 邏輯顛倒明顯，理解布林標籤語義即可發現問題。
