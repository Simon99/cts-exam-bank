# Q005: TimingConstraintsTest 取消作業失敗

## 測試名稱
`android.jobscheduler.cts.TimingConstraintsTest#testCancel`

## 失敗現象
```
junit.framework.AssertionFailedError: Cancel failed: job executed when it shouldn't have.
    at android.jobscheduler.cts.TimingConstraintsTest.testCancel(TimingConstraintsTest.java:64)
```

## 測試環境
- 標準測試環境
- 作業設定了最小延遲

## 測試描述
測試取消已排程的作業功能。排程作業後立即取消，作業不應該執行。

## 複現步驟
1. 排程一個設有 5 秒最小延遲的作業
2. 立即取消該作業
3. 嘗試執行已滿足的作業
4. 驗證作業沒有執行

## 預期行為
取消的作業不應該執行。

## 實際行為
作業仍然執行了，表示取消操作沒有正確清除作業。

## 難度
Easy

## 提示
檢查 `TimeController` 中的 `maybeStopTrackingJobLocked()` 方法，確認作業是否被正確移除。
