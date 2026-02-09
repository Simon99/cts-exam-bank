# CTS Hard Q009: DisplayInfo 狀態變化通知機制 Bug

## 問題描述

測試 `android.display.cts.DefaultDisplayModeTest` 中的 `testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents` 測試失敗。

### 現象

1. 調用 `setGlobalUserPreferredDisplayMode()` 設置新的 display mode
2. 等待 `DisplayListener.onDisplayChanged()` 回調
3. 回調沒有被觸發，測試等待超時

### 相關日誌

```
D DisplayManager: Delivering display event: displayId=0, event=2
D DisplayManager: DLD(DISPLAY_CHANGED, display=0, listener=TestDisplayListener)
// handleDisplayEventInner() 判斷 DisplayInfo 沒有變化
// onDisplayChanged 沒有被呼叫
```

### 測試代碼片段

```java
// DefaultDisplayModeTest.java
mDisplayManager.setGlobalUserPreferredDisplayMode(newDefaultMode);
// 等待 onDisplayChanged 回調
assertTrue(setUserPrefModeSignal.await(DISPLAY_CHANGE_TIMEOUT_SECS, TimeUnit.SECONDS));
```

### 影響

- Display mode 偏好設置變化時應用無法收到通知
- 依賴 DisplayListener 的功能失效
- 測試超時失敗

## 任務

1. 定位導致 `onDisplayChanged` 回調缺失的 bug
2. 理解 DisplayManagerGlobal 中的 forceUpdate 機制
3. 找出哪個欄位的比較遺漏導致了問題
4. 解釋為什麼其他 display 變化（如 rotation）不受影響

## 提示

- 問題涉及 `DisplayInfo.equals()` 方法
- 注意 `handleDisplayEventInner()` 中的 `forceUpdate` 參數
- 不同路徑（WindowManager vs DisplayManagerService）使用不同的 forceUpdate 值

## 相關檔案

- `frameworks/base/core/java/android/view/DisplayInfo.java`
- `frameworks/base/core/java/android/hardware/display/DisplayManagerGlobal.java`

## 難度分析

這是一個 **hard** 級別的題目，因為：
1. 需要理解 DisplayManagerGlobal 中的 forceUpdate 機制
2. 需要追蹤不同 display 事件的觸發路徑
3. 涉及 equals() 方法與狀態變化通知的關係
