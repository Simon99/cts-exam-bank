# Q002: StorageConstraintTest 存儲狀態判斷錯誤

## 測試名稱
`android.jobscheduler.cts.StorageConstraintTest#testNotLowConstraintExecutes`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with storage not low constraint did not fire when storage not low.
    at android.jobscheduler.cts.StorageConstraintTest.testNotLowConstraintExecutes(StorageConstraintTest.java:68)
```

## 測試環境
- 存儲空間充足
- 系統廣播 ACTION_DEVICE_STORAGE_OK 已發送

## 測試描述
測試排程一個需要存儲空間充足的作業，當設備存儲空間不低時，作業應該執行。

## 複現步驟
1. 設定存儲狀態為不低 (setStorageStateLow(false))
2. 排程一個 `setRequiresStorageNotLow(true)` 的作業
3. 等待作業執行

## 預期行為
存儲空間充足時，作業應該執行。

## 實際行為
作業沒有執行，約束條件顯示為不滿足。

## 難度
Easy

## 提示
檢查 `StorageController` 中的 `isStorageNotLow()` 返回值邏輯。
