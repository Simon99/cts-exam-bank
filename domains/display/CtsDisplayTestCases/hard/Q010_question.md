# CTS Hard Q010: DisplayInfo Parcel 序列化欄位順序錯誤

## 問題描述

測試 `android.display.cts.DefaultDisplayModeTest` 中的 `testSetUserPreferredDisplayModeForSpecificDisplay` 測試失敗。

### 現象

1. 調用 `display.setUserPreferredDisplayMode(newMode)` 設置偏好 mode
2. 調用 `display.getUserPreferredDisplayMode()` 獲取偏好 mode
3. 返回的 mode 與設置的不一致

### 測試代碼片段

```java
// DefaultDisplayModeTest.java
mDefaultDisplay.setUserPreferredDisplayMode(newDefaultMode);
assertTrue(mDefaultDisplay.getUserPreferredDisplayMode()
        .matches(newDefaultMode.getPhysicalWidth(),
                newDefaultMode.getPhysicalHeight(),
                newDefaultMode.getRefreshRate()));
// 測試失敗：matches() 返回 false
```

### 相關現象

- `getDefaultMode()` 返回的 mode 也不正確
- 只在跨進程調用時出現問題
- 同進程內直接訪問欄位是正確的

### 影響

- Display mode 偏好設置功能失效
- 用戶設置的顯示模式無法正確生效
- `getDefaultMode()` 和 `getUserPreferredDisplayMode()` 返回錯誤結果

## 任務

1. 定位導致 mode 資訊錯誤的 bug
2. 理解 Parcelable 序列化/反序列化的順序要求
3. 找出 writeToParcel 和 readFromParcel 之間的順序不一致
4. 解釋為什麼這個問題只在跨進程時出現

## 提示

- 問題涉及 `DisplayInfo` 的 Parcel 序列化
- 比較 `writeToParcel()` 和 `readFromParcel()` 中的欄位順序
- 關注與 mode 相關的欄位

## 相關檔案

- `frameworks/base/core/java/android/view/DisplayInfo.java`

## 難度分析

這是一個 **hard** 級別的題目，因為：
1. 需要理解 Parcelable 的序列化/反序列化機制
2. 需要比對兩個方法中的欄位順序
3. 需要理解跨進程 IPC 資料傳輸的原理
4. Bug 很微妙，只交換了兩個相似欄位的順序
