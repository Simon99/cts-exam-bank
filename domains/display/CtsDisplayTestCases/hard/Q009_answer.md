# Q009 答案

## Bug 位置

**檔案:** `frameworks/base/core/java/android/view/DisplayInfo.java`
**方法:** `equals(DisplayInfo)`
**行號:** 約 429 行

## Bug 描述

`DisplayInfo.equals()` 方法遺漏了 `defaultModeId` 欄位的比較。

## 原始代碼（正確）

```java
public boolean equals(DisplayInfo other) {
    return other != null
            && ...
            && modeId == other.modeId
            && renderFrameRate == other.renderFrameRate
            && defaultModeId == other.defaultModeId  // ← 這行被遺漏
            && userPreferredModeId == other.userPreferredModeId
            && ...
}
```

## Bug 代碼

```java
public boolean equals(DisplayInfo other) {
    return other != null
            && ...
            && modeId == other.modeId
            && renderFrameRate == other.renderFrameRate
            // ← 遺漏 defaultModeId 比較
            && userPreferredModeId == other.userPreferredModeId
            && ...
}
```

## 修復方法

在 `equals()` 方法中添加 `defaultModeId` 的比較：
```java
&& defaultModeId == other.defaultModeId
```

## Bug 觸發機制

1. 應用調用 `DisplayManager.setGlobalUserPreferredDisplayMode(newMode)`
2. `DisplayManagerService` 更新 `defaultModeId` 欄位
3. `DisplayManagerService` 發送 `EVENT_DISPLAY_CHANGED` 事件
4. `DisplayManagerCallback.onDisplayEvent()` 收到事件，使用 `forceUpdate=false`
5. `handleDisplayEventInner()` 調用 `equals()` 比較新舊 `DisplayInfo`
6. 因為 `equals()` 沒有比較 `defaultModeId`，返回 `true`（認為沒有變化）
7. `onDisplayChanged()` 不被調用
8. 測試等待 `onDisplayChanged` 超時失敗

## 為什麼 rotation 變化不受影響？

rotation 變化透過 WindowManager 路徑觸發：
```
Activity.setRequestedOrientation()
    → WindowManager 
    → DisplayManagerGlobal.handleDisplayChangeFromWindowManager()
    → handleDisplayEvent(..., true /* forceUpdate */)
```

`forceUpdate=true` 時，`handleDisplayEventInner()` 會繞過 `equals()` 檢查，直接觸發 `onDisplayChanged()`。

## 核心洞察

`handleDisplayEventInner()` 的邏輯：
```java
if (info != null && (forceUpdate || !info.equals(mDisplayInfo))) {
    mListener.onDisplayChanged(displayId);
}
```

- **WindowManager 路徑**: `forceUpdate=true`，繞過 equals()
- **DisplayManagerService 路徑**: `forceUpdate=false`，依賴 equals()

因此，`equals()` 方法的任何遺漏只會影響透過 `DisplayManagerService` 直接發送的事件。

## 學習要點

1. 理解 Android Display 子系統的事件傳遞機制
2. 理解 forceUpdate 參數的作用和設計意圖
3. equals() 方法必須比較所有可能變化的欄位
4. 不同路徑可能有不同的行為特性
