# Q001: ConnectivityConstraintTest Data Saver 模式下加急作業網絡限制失效

## 測試名稱
`android.jobscheduler.cts.ConnectivityConstraintTest#testBgExpeditedJobDoesNotBypassDataSaver`

## 失敗現象
```
junit.framework.AssertionFailedError: BG expedited job requiring connectivity fired with Data Saver on.
    at android.jobscheduler.cts.ConnectivityConstraintTest.testBgExpeditedJobDoesNotBypassDataSaver(ConnectivityConstraintTest.java:455)
```

## 測試環境
- WiFi 設為計量或使用行動數據
- Data Saver 開啟
- 應用在背景執行加急作業

## 測試描述
測試背景加急作業在 Data Saver 開啟時不應該繞過網絡限制。只有前台加急作業可以繞過。

## 複現步驟
1. 設定 WiFi 為計量網絡或使用行動數據
2. 開啟 Data Saver
3. 排程一個背景加急作業（需要任意網絡）
4. 嘗試執行作業
5. 驗證作業沒有執行

## 預期行為
背景加急作業在 Data Saver 開啟時不應執行。

## 實際行為
作業錯誤地執行了。

## 難度
Hard

## 提示
1. 檢查 `ConnectivityController` 中 Data Saver 相關的檢查
2. 檢查 `BackgroundJobsController` 和前/背景狀態判斷
3. 確認 `QuotaController` 或 `TareController` 中的 expedited job 特殊處理
4. 追蹤 `isJobRunnable()` 的多層判斷邏輯
