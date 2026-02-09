# Q003: JobThrottlingTest 配額控制與多重防火牆繞過

## 測試名稱
`android.jobscheduler.cts.ConnectivityConstraintTest#testExpeditedJobDoesNotBypassSimultaneousFirewalls_withDataSaver`

## 失敗現象
```
junit.framework.AssertionFailedError: Expedited job fired with multiple firewalls, including data saver.
    at android.jobscheduler.cts.ConnectivityConstraintTest.testExpeditedJobDoesNotBypassSimultaneousFirewalls_withDataSaver(ConnectivityConstraintTest.java:488)
```

## 測試環境
- 應用處於受限 standby bucket
- Battery Saver 開啟
- Data Saver 開啟
- 設備未充電

## 測試描述
測試當多個"防火牆"同時啟用時（包括 Data Saver），加急作業不應該執行。

## 複現步驟
1. 將應用設為 restricted standby bucket
2. 拔掉電源
3. 開啟 Battery Saver
4. 開啟 Data Saver
5. 排程一個需要任意網絡的加急作業
6. 驗證作業沒有執行

## 預期行為
當 Data Saver 與其他限制同時啟用時，加急作業不應執行。

## 實際行為
作業錯誤地執行了。

## 難度
Hard

## 提示
1. 檢查 `QuotaController` 中的配額邏輯
2. 檢查 `BackgroundJobsController` 的 standby bucket 處理
3. 檢查 `ConnectivityController` 的 Data Saver 判斷
4. 理解多個限制如何協同工作
