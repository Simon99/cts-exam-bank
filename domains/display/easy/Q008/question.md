# CTS 除錯練習題 DIS-E008

## 題目資訊
- **難度**: Easy
- **預計時間**: 15 分鐘
- **領域**: Display (虛擬顯示)

## 失敗的 CTS 測試

```
android.hardware.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay
```

### 測試失敗訊息

```
junit.framework.AssertionFailedError: Private virtual display should have expected unique ID format
Expected: <virtual:com.android.cts.display:private_test_display>
Actual:   <virtual:com.android.cts.displayprivate_test_display>
    at android.hardware.display.cts.VirtualDisplayTest.testPrivateVirtualDisplay(VirtualDisplayTest.java:234)
```

## 背景說明

`VirtualDisplayTest#testPrivateVirtualDisplay` 測試驗證當應用程式創建私有虛擬顯示時，系統會生成正確格式的唯一識別碼 (unique ID)。

測試流程：
1. 創建一個指定 uniqueId 的 VirtualDisplayConfig
2. 使用該配置創建私有虛擬顯示
3. 驗證生成的 display unique ID 符合預期格式

## 相關程式碼區域

請檢查以下檔案中的 `generateDisplayUniqueId()` 方法：

```
frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java
```

## 問題

1. 找出導致 unique ID 格式錯誤的 bug
2. 說明為什麼這個 bug 會導致測試失敗
3. 提供修復方案

## 提示

- 觀察 Expected 和 Actual 的差異
- 檢查字串拼接邏輯中的分隔符處理
- 注意當 `config.getUniqueId() != null` 時的處理方式
