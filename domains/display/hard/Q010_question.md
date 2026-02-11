# CTS 題目：Display Mode 設置與清除事件

**難度**：Hard  
**時間限制**：40 分鐘  
**CTS 測試**：`android.hardware.display.cts.DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents`

---

## 問題描述

QA 團隊報告了一個與 Display Mode 設置相關的 CTS 測試失敗。

### 失敗的測試

```
android.hardware.display.cts.DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents
```

### 測試預期行為

1. 調用 `DisplayManager.setGlobalUserPreferredDisplayMode(mode)` 設置全局顯示模式
2. 應該產生 `EVENT_DISPLAY_CHANGED` 事件
3. 調用 `DisplayManager.clearGlobalUserPreferredDisplayMode()` 清除全局顯示模式
4. 也應該產生 `EVENT_DISPLAY_CHANGED` 事件

### 實際行為

- 設置全局顯示模式時，正確產生了 display changed 事件
- 清除全局顯示模式時，**沒有產生 display changed 事件**

### 相關日誌

```
DisplayManagerService: setUserPreferredDisplayModeInternal displayId=-1 mode=Mode{1920x1080 60.0Hz}
DisplayManagerService: storeModeInGlobalSettingsLocked mode=Mode{1920x1080 60.0Hz}
# ... 設備收到通知，產生 EVENT_DISPLAY_CHANGED

DisplayManagerService: setUserPreferredDisplayModeInternal displayId=-1 mode=null
# 注意：沒有 storeModeInGlobalSettingsLocked 的日誌
# 沒有 EVENT_DISPLAY_CHANGED 事件
```

---

## 你的任務

1. 分析問題根因
2. 找出有 bug 的程式碼位置
3. 解釋為什麼 clear 操作沒有產生 display changed 事件
4. 提供修復方案

---

## 相關源碼路徑

```
frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
```

### 重點函數

- `setUserPreferredDisplayModeInternal(int displayId, Display.Mode mode)`
- `storeModeInGlobalSettingsLocked(...)`
- `storeModeInPersistentDataStoreLocked(...)`

---

## 提示

1. 當 `displayId == Display.INVALID_DISPLAY` 時，表示設置/清除的是**全局**顯示模式
2. 當 `mode == null` 時，表示這是**清除**操作
3. `storeModeInGlobalSettingsLocked` 會遍歷所有 DisplayDevice 並調用 `setUserPreferredDisplayModeLocked`
4. `setUserPreferredDisplayModeLocked` 內部會調用 `updateDeviceInfoLocked()` 來發送 display changed 事件
5. 設置操作和清除操作應該有對稱的事件行為

---

## 評分標準

| 項目 | 分數 |
|------|------|
| 正確定位 bug 位置 | 25% |
| 解釋根因（set vs clear 的不對稱處理） | 25% |
| 理解事件傳遞機制 | 25% |
| 提供正確的修復方案 | 25% |
