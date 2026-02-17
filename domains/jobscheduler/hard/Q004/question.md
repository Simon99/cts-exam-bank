# Q004: FlexibilityConstraintTest 彈性約束協調失敗

## 測試名稱
`android.jobscheduler.cts.FlexibilityConstraintTest` (多個測試)

## 失敗現象
```
多個 FlexibilityConstraintTest 測試失敗，作業在不應該執行時執行或應該執行時未執行。
```

## 測試環境
- 各種約束組合
- 彈性控制器啟用

## 測試描述
FlexibilityController 協調多個約束，允許系統根據情況靈活執行作業。

## 複現步驟
1. 排程具有多個軟約束的作業
2. 模擬各種設備狀態組合
3. 驗證作業是否在正確時機執行

## 預期行為
FlexibilityController 應該正確協調約束，優化作業執行時機。

## 實際行為
約束評估不一致，導致作業執行時機錯誤。

## 難度
Hard

## 提示
1. 檢查 `FlexibilityController` 與其他 Controller 的交互
2. 確認 `BatteryController` 通知 `FlexibilityController` 的邏輯
3. 檢查 `TimeController` 和 `FlexibilityController` 的約束滿足通知
4. 追蹤約束滿足度計算邏輯
