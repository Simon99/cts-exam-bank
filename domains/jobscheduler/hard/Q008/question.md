# Q008: TimeController Deadline 約束評估時機錯誤導致作業提前執行

## 測試名稱
`android.jobscheduler.cts.TimingConstraintsTest#testJobWithDeadlineDoesNotRunEarly`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with deadline constraint ran before the deadline
    at android.jobscheduler.cts.TimingConstraintsTest.testJobWithDeadlineDoesNotRunEarly(TimingConstraintsTest.java:165)
```

## 測試環境
- 排程一個帶有 deadline 但沒有 delay 的作業
- 設置 deadline 為 5 分鐘後
- 其他約束（如網絡）未滿足

## 測試描述
帶有 deadline 約束的作業，在 deadline 到達前，如果其他約束未滿足，不應該被執行。只有當 deadline 到達時，才會忽略其他軟約束強制執行。

## 複現步驟
1. 排程一個作業：deadline=5分鐘，需要網絡，當前無網絡
2. 立即強制執行作業
3. 驗證作業不會啟動（因為網絡約束未滿足，deadline 未到）
4. 等待 deadline 到達後，驗證作業是否強制執行

## 預期行為
作業在 deadline 到達前，因為網絡約束未滿足而不執行；deadline 到達後強制執行。

## 實際行為
作業在 deadline 之前就被錯誤地執行了。

## 難度
Hard

## 提示
1. 檢查 `TimeController.evaluateDeadlineConstraint()` 的返回值使用
2. 查看 `maybeStartTrackingJobLocked()` 中的早期約束檢查
3. 確認 `wouldBeReadyWithConstraintLocked()` 的邏輯
4. 注意 `CONSTRAINT_DEADLINE` 與其他約束的交互
5. 檢查 `setDeadlineConstraintSatisfied()` 的調用時機
