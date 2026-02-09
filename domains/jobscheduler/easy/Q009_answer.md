# Q009: 答案解析

## 問題根因
`StorageController.java` 中收到 ACTION_DEVICE_STORAGE_LOW 廣播後，沒有調用狀態變化通知。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/StorageController.java`

## 錯誤代碼
```java
@Override
public void onReceive(Context context, Intent intent) {
    onReceiveInternal(intent);
}

@VisibleForTesting
public void onReceiveInternal(Intent intent) {
    final String action = intent.getAction();
    if (Intent.ACTION_DEVICE_STORAGE_LOW.equals(action)) {
        if (DEBUG) {
            Slog.d(TAG, "Available storage too low to do work.");
        }
        mStorageLow = true;
        // BUG: 缺少 maybeReportNewStorageState() 調用
    } else if (Intent.ACTION_DEVICE_STORAGE_OK.equals(action)) {
        // ...
        mStorageLow = false;
        maybeReportNewStorageState();
    }
}
```

## 正確代碼
```java
public void onReceiveInternal(Intent intent) {
    final String action = intent.getAction();
    if (Intent.ACTION_DEVICE_STORAGE_LOW.equals(action)) {
        if (DEBUG) {
            Slog.d(TAG, "Available storage too low to do work.");
        }
        mStorageLow = true;
        maybeReportNewStorageState();  // 需要添加這行
    } else if (Intent.ACTION_DEVICE_STORAGE_OK.equals(action)) {
        // ...
    }
}
```

## 修復步驟
1. 打開 `StorageController.java`
2. 找到內部類 `StorageTracker` 中的 `onReceiveInternal()` 方法
3. 在處理 `ACTION_DEVICE_STORAGE_LOW` 時添加 `maybeReportNewStorageState()` 調用

## 測試驗證
```bash
atest android.jobscheduler.cts.StorageConstraintTest#testJobStoppedWhenStorageLow
```

## 相關知識點
- 約束條件變化時需要通知 JobScheduler 重新評估作業狀態
- `maybeReportNewStorageState()` 會更新所有追蹤作業的約束狀態
