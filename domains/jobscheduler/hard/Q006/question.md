# Q006: ThermalStatusRestriction 熱限流閾值判斷錯誤導致作業過早停止

## 測試名稱
`android.jobscheduler.cts.JobThrottlingTest#testBackgroundEJsThermal`

## 失敗現象
```
junit.framework.AssertionFailedError: Job stopped below thermal throttling threshold
    at android.jobscheduler.cts.JobThrottlingTest.testBackgroundEJsThermal(JobThrottlingTest.java:531)
```

## 測試環境
- 設備溫度狀態為 THERMAL_STATUS_MODERATE（中等）
- 執行背景加急作業（EJ）
- 期望作業在 SEVERE 級別才被停止

## 測試描述
測試背景加急作業在熱限流場景下的行為。根據設計：
- LIGHT (1): 只限制 MIN/LOW 優先級作業
- MODERATE (2): 限制普通作業，但 EJ 和 UIJ 應該可以運行
- SEVERE (3): 停止所有作業

## 複現步驟
1. 排程一個背景加急作業
2. 執行作業並等待啟動
3. 使用 `adb shell cmd thermalservice override-status 2` 設置為 MODERATE
4. 驗證作業是否繼續運行
5. 設置為 SEVERE 後驗證作業是否停止

## 預期行為
EJ 在 MODERATE 級別下應該繼續運行，只有在 SEVERE 級別才停止。

## 實際行為
EJ 在 MODERATE 級別就被錯誤停止。

## 難度
Hard

## 提示
1. 檢查 `ThermalStatusRestriction.isJobRestricted()` 中的閾值判斷
2. 注意 `HIGHER_PRIORITY_THRESHOLD` 和 `UPPER_THRESHOLD` 的使用
3. 確認 `shouldTreatAsExpeditedJob()` 的檢查順序
4. 驗證 `mThermalStatus` 的比較運算符是否正確
