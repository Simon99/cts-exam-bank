# Q002: 答案解析

## 問題根因
`StorageController.java` 中的 `isStorageNotLow()` 方法返回值邏輯錯誤。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/StorageController.java`

## 錯誤代碼
```java
public boolean isStorageNotLow() {
    return mStorageLow;  // BUG: 應該返回 !mStorageLow
}
```

## 正確代碼
```java
public boolean isStorageNotLow() {
    return !mStorageLow;
}
```

## 修復步驟
1. 打開 `StorageController.java`
2. 找到內部類 `StorageTracker` 中的 `isStorageNotLow()` 方法
3. 將 `return mStorageLow;` 修改為 `return !mStorageLow;`

## 測試驗證
```bash
atest android.jobscheduler.cts.StorageConstraintTest#testNotLowConstraintExecutes
atest android.jobscheduler.cts.StorageConstraintTest#testNotLowConstraintFails
```

## 相關知識點
- StorageController 追蹤存儲狀態的機制
- ACTION_DEVICE_STORAGE_LOW 和 ACTION_DEVICE_STORAGE_OK 廣播
- 約束狀態的布林邏輯

## 調試提示
查看 logcat 中 `JobScheduler.Storage` tag 的日誌：
```bash
adb logcat -s JobScheduler.Storage
```
