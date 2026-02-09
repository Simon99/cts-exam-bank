# CTS Hard Q009: DisplayInfo 狀態變化通知機制 Bug

## 問題描述

測試 `android.display.cts.DisplayTest` 中的 `testDisplayListener` 相關測試出現不穩定的行為。

### 現象

1. 使用 VirtualDisplay 創建虛擬顯示
2. 通過 `setSurfaceSize()` 改變顯示尺寸或其他屬性
3. 註冊的 `DisplayListener.onDisplayChanged()` 有時候不會被呼叫
4. 特別是當顯示的 `rotation` 屬性變化時，回調經常缺失

### 相關日誌

```
D DisplayManager: Delivering display event: displayId=0, event=2
D DisplayManager: DLD(DISPLAY_CHANGED, display=0, listener=TestDisplayListener)
// 但 onDisplayChanged 沒有被呼叫
```

### 影響

- 應用無法正確感知 Display 屬性變化
- 自動旋轉功能可能不正確響應
- Presentation 和多螢幕應用可能出現同步問題

## 任務

1. 定位導致 `onDisplayChanged` 回調缺失的 bug
2. 找出涉及的跨檔案邏輯問題
3. 解釋 bug 的觸發條件和影響範圍

## 提示

- 問題涉及多個檔案之間的狀態同步
- 檢查 DisplayInfo 的比較邏輯
- 思考為什麼有些屬性變化會觸發回調，有些不會

## 相關檔案

- `frameworks/base/core/java/android/view/DisplayInfo.java`
- `frameworks/base/core/java/android/hardware/display/DisplayManagerGlobal.java`
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`
