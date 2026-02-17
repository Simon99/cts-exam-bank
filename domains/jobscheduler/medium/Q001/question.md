# Q001: ConnectivityConstraintTest 網絡約束不正確執行

## 測試名稱
`android.jobscheduler.cts.ConnectivityConstraintTest#testUnmeteredConstraintFails_withMobile`

## 失敗現象
```
junit.framework.AssertionFailedError: Job requiring unmetered connectivity still executed on mobile.
    at android.jobscheduler.cts.ConnectivityConstraintTest.testUnmeteredConstraintFails_withMobile(ConnectivityConstraintTest.java:385)
```

## 測試環境
- WiFi 已禁用
- 僅有行動數據連接
- 網絡為計量網絡 (metered)

## 測試描述
測試一個需要非計量網絡 (unmetered) 的作業，在僅有行動數據連接時不應該執行。

## 複現步驟
1. 禁用 WiFi，確保只有行動數據連接
2. 排程一個 `setRequiredNetworkType(NETWORK_TYPE_UNMETERED)` 的作業
3. 嘗試執行作業
4. 驗證作業沒有執行

## 預期行為
在行動數據 (通常是計量網絡) 下，需要非計量網絡的作業不應該執行。

## 實際行為
作業在行動數據連接下錯誤地執行了。

## 難度
Medium

## 提示
1. 檢查 `ConnectivityController` 中網絡類型的判斷邏輯
2. 確認 `NETWORK_TYPE_UNMETERED` 的滿足條件檢查
3. 可能需要添加 log 來追蹤網絡約束的評估過程
