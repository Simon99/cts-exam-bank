# SEC-E007 Answer: Device Locked 狀態返回錯誤

## 正確答案
**B) `isDeviceLocked()` 硬編碼返回 `false`**

## 問題根因
在 `RootOfTrust.java` 的 `isDeviceLocked()` 方法中，
沒有返回實際解析的狀態值，而是硬編碼返回 `false`。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

## 修復方式
```java
// 錯誤的代碼
public boolean isDeviceLocked() {
    return false;  // BUG: 硬編碼
}

// 正確的代碼
public boolean isDeviceLocked() {
    return mDeviceLocked;
}
```

## 為什麼其他選項不對

**A)** 拼寫錯誤會導致編譯錯誤或 null，不會是 false。

**C)** 錯誤的 byte 位置會解析出錯誤的值，可能是 true 或其他，不一定是 false。

**D)** 返回 verifiedBootState 會返回整數，類型不匹配，編譯會報錯。

## 相關知識
- Device Locked = bootloader 已鎖定，無法刷入未簽名的映像
- 這是 Android 驗證開機 (Verified Boot) 的一部分
- Root of Trust 儲存在硬體安全模組中

## 難度說明
**Easy** - 硬編碼返回 false 是最簡單的錯誤類型。
