# Q001 答案：OBB 掛載回調狀態碼與監聯器處理錯誤

## Bug 位置

### Bug 1: StorageManagerService.java
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 2583 行
**問題:** 掛載成功後通知狀態碼錯誤，使用 `ERROR_INTERNAL` 而非 `MOUNTED`

### Bug 2: OnObbStateChangeListener.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/OnObbStateChangeListener.java`
**行號:** 約 48 行
**問題:** `MOUNTED` 常量值被改為 2（原本是 1），與 CTS 測試期望值不符

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
mObbState.notifyStateChange(action, OnObbStateChangeListener.ERROR_INTERNAL);

// 正確代碼
mObbState.notifyStateChange(action, OnObbStateChangeListener.MOUNTED);
```

### 修復 Bug 2:
```java
// 錯誤代碼
public static final int MOUNTED = 2;

// 正確代碼
public static final int MOUNTED = 1;
```

## 根本原因分析

這是一個典型的**多層錯誤**：
1. Service 層回傳了錯誤的狀態碼
2. 即使回傳正確的狀態碼，常量定義也被修改了

兩個 bug 相互掩蓋：
- 單獨修復 Bug 1 無法完全解決問題（因為 MOUNTED 值錯誤）
- 單獨修復 Bug 2 也無法解決問題（因為 Service 根本沒用 MOUNTED）

## 調試思路

1. CTS 測試檢查 callback 收到的狀態碼是否為 1
2. 追蹤 `notifyStateChange()` 的調用，發現傳入 `ERROR_INTERNAL`
3. 嘗試修改為 `MOUNTED`，但測試仍失敗
4. 檢查 `MOUNTED` 常量定義，發現值被修改
5. 修復兩處後測試通過
