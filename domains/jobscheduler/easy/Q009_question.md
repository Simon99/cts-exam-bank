# Q009: StorageConstraintTest 存儲狀態變化未停止作業

## 測試名稱
`android.jobscheduler.cts.StorageConstraintTest#testJobStoppedWhenStorageLow`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with storage not low constraint was not stopped when storage became low.
    at android.jobscheduler.cts.StorageConstraintTest.testJobStoppedWhenStorageLow(StorageConstraintTest.java:95)
```

## 測試環境
- 初始存儲狀態為充足
- 作業開始執行後存儲變低

## 測試描述
測試當存儲狀態從充足變為不足時，正在執行的需要存儲不低的作業應該被停止。

## 複現步驟
1. 設定存儲狀態為不低
2. 排程並執行一個 `setRequiresStorageNotLow(true)` 的作業
3. 作業開始執行後，將存儲狀態設為低
4. 驗證作業被停止

## 預期行為
存儲變低時，作業應該收到停止信號並停止執行。

## 實際行為
作業沒有被停止，繼續執行。

## 難度
Easy

## 提示
檢查 `StorageController` 中存儲狀態變化時的處理邏輯，確認是否正確通知了狀態變化。
