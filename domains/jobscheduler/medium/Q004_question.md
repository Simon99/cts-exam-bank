# Q004: ConnectivityConstraintTest 網絡轉換時作業被錯誤停止

## 測試名稱
`android.jobscheduler.cts.ConnectivityConstraintTest#testConnectivityConstraintExecutes_transitionNetworks`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with connectivity constraint was stopped when network transitioned to WiFi.
    at android.jobscheduler.cts.ConnectivityConstraintTest.testConnectivityConstraintExecutes_transitionNetworks(ConnectivityConstraintTest.java:175)
```

## 測試環境
- 初始網絡：行動數據
- 作業開始執行後連接 WiFi
- 作業僅要求 `NETWORK_TYPE_ANY`

## 測試描述
測試網絡從行動數據切換到 WiFi 時，需要任意網絡連接的作業不應該被停止。

## 複現步驟
1. 禁用 WiFi，確保只有行動數據
2. 排程一個 `setRequiredNetworkType(NETWORK_TYPE_ANY)` 的作業
3. 作業開始執行
4. 連接 WiFi（網絡轉換）
5. 驗證作業沒有被停止

## 預期行為
網絡從行動數據切換到 WiFi 時，只要求任意網絡的作業應該繼續執行，並收到網絡變化通知。

## 實際行為
作業在網絡轉換時被停止了。

## 難度
Medium

## 提示
1. 檢查 `ConnectivityController` 中網絡變化時的處理邏輯
2. 確認 `isSatisfied()` 方法在網絡變化時的判斷
