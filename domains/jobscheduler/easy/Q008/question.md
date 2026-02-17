# Q008: TimingConstraintsTest 期限過期判斷錯誤

## 測試名稱
`android.jobscheduler.cts.TimingConstraintsTest#testJobParameters_expiredDeadline`

## 失敗現象
```
junit.framework.AssertionFailedError: Job does not show its deadline as expired
    at android.jobscheduler.cts.TimingConstraintsTest.testJobParameters_expiredDeadline(TimingConstraintsTest.java:116)
```

## 測試環境
- 存儲狀態設為低
- 作業有期限約束
- 期限已過期

## 測試描述
測試當作業因期限過期而執行時，`JobParameters.isOverrideDeadlineExpired()` 應返回 true。

## 複現步驟
1. 設定存儲狀態為低 (作業的存儲約束無法滿足)
2. 排程一個需要存儲不低且設有短期限 (2秒) 的作業
3. 等待期限過期
4. 作業因期限過期而強制執行
5. 檢查 `JobParameters.isOverrideDeadlineExpired()` 返回值

## 預期行為
當作業因期限過期而執行時，`isOverrideDeadlineExpired()` 應返回 true。

## 實際行為
`isOverrideDeadlineExpired()` 返回 false。

## 難度
Easy

## 提示
檢查 `TimeController` 中設置期限過期狀態的邏輯。
