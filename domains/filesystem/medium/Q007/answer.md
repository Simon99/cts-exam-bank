# Q007 答案：StorageVolumeCallback 觸發條件與監聽器註冊錯誤

## Bug 位置

### Bug 1: StorageManagerService.java
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 1923 行
**問題:** 只在狀態相同時才觸發回調（`oldState == newState`）

### Bug 2: StorageEventListener.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageEventListener.java`
**行號:** 約 48 行
**問題:** 默認實現在狀態相同時返回，而非空實現

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
if (callback != null && oldState == newState) {

// 正確代碼
if (callback != null) {
```

### 修復 Bug 2:
```java
// 錯誤代碼
public void onStorageStateChanged(String path, String oldState, String newState) {
    if (oldState.equals(newState)) return;
}

// 正確代碼
public void onStorageStateChanged(String path, String oldState, String newState) {
    // Default implementation does nothing
}
```

## 根本原因分析

這是一個 **回調觸發條件** 雙重錯誤：

1. Service 層只在狀態「沒有變化」時才觸發回調（邏輯相反）
2. 監聽器默認實現過早過濾相同狀態

正確行為：
- 狀態變化時觸發回調
- 監聽器收到後自行處理

## 調試思路

1. CTS 測試註冊 callback，觸發掛載操作
2. Callback 未被調用
3. 追蹤 `notifyStorageStateChanged()` 調用
4. 發現條件判斷錯誤（`oldState == newState`）
5. 修復後部分測試仍失敗，檢查 listener 默認實現
