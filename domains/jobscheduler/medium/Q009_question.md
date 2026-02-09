# Q009: TimingConstraintsTest 低彈性週期作業錯誤執行

## 測試名稱
`android.jobscheduler.cts.TimingConstraintsTest#testSchedulePeriodic_lowFlex`

## 失敗現象
```
junit.framework.AssertionFailedError: Timed out waiting for periodic jobs to execute
    at android.jobscheduler.cts.TimingConstraintsTest.testSchedulePeriodic_lowFlex(TimingConstraintsTest.java:59)
```

## 測試環境
- 標準測試環境
- 週期性作業設有最小彈性窗口

## 測試描述
測試週期性作業不應在彈性窗口之外執行。設有最小彈性窗口的作業在窗口外應該保持等待狀態。

## 複現步驟
1. 排程一個週期為 `getMinPeriodMillis()`，彈性為 `getMinFlexMillis()` 的週期性作業
2. 在彈性窗口之前嘗試執行
3. 驗證作業沒有執行
4. 驗證作業狀態為 waiting 且 not ready

## 預期行為
在彈性窗口之前，`runSatisfiedJob()` 不應該執行作業，測試應該等待超時（預期執行次數為 0）。

## 實際行為
作業在彈性窗口之外也被執行了。

## 難度
Medium

## 提示
1. 檢查 `TimeController` 中週期性作業彈性窗口的計算
2. 確認 `isInFlexWindow()` 的判斷邏輯
