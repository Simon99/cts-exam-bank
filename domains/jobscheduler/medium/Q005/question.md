# Q005: ExpeditedJobTest 加急作業 UID 狀態錯誤

## 測試名稱
`android.jobscheduler.cts.ExpeditedJobTest#testJobUidState_withRequiredNetwork`

## 失敗現象
```
junit.framework.AssertionFailedError: expected:<1> but was:<0>
    at android.jobscheduler.cts.ExpeditedJobTest.testJobUidState_withRequiredNetwork(ExpeditedJobTest.java:85)
```

## 測試環境
- 螢幕關閉
- 網絡可用
- 加急作業帶有網絡約束

## 測試描述
測試帶有網絡約束的加急作業執行時，應該具有受限制的網絡能力 (PROCESS_CAPABILITY_POWER_RESTRICTED_NETWORK)。

## 複現步驟
1. 關閉螢幕
2. 啟用所有網絡
3. 排程一個加急作業並設定 `NETWORK_TYPE_ANY`
4. 強制執行作業
5. 驗證作業的 UID 狀態包含正確的 capabilities

## 預期行為
加急作業執行時應該具有 `PROCESS_CAPABILITY_POWER_RESTRICTED_NETWORK` (值為 1)。

## 實際行為
作業執行時的 capabilities 為 0，缺少網絡能力。

## 難度
Medium

## 提示
1. 檢查 `JobConcurrencyManager` 或 `JobServiceContext` 中設置作業能力的邏輯
2. 追蹤 expedited job 的特殊處理路徑
