# Q003: TimingConstraintsTest 延遲約束未滿足

## 測試名稱
`android.jobscheduler.cts.TimingConstraintsTest#testExplicitZeroLatency`

## 失敗現象
```
junit.framework.AssertionFailedError: Failed to execute job with explicit zero min latency
    at android.jobscheduler.cts.TimingConstraintsTest.testExplicitZeroLatency(TimingConstraintsTest.java:82)
```

## 測試環境
- 標準測試環境
- 無特殊約束條件

## 測試描述
測試排程一個最小延遲為 0 的作業，作業應該立即執行。

## 複現步驟
1. 建立一個 `setMinimumLatency(0L)` 的 JobInfo
2. 排程作業
3. 觸發已滿足的作業執行
4. 等待作業執行

## 預期行為
最小延遲為 0 的作業應該立即被標記為延遲約束滿足，並且可以執行。

## 實際行為
作業的延遲約束未被標記為滿足，作業無法執行。

## 難度
Easy

## 提示
檢查 `TimeController` 中評估延遲約束的邏輯，特別是邊界條件處理。
