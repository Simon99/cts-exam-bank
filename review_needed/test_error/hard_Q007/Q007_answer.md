# Q007 答案解析

## Bug 概述

這是一個涉及 **3 個檔案交互** 的跨檔案狀態同步問題。當 VirtualDisplay 被 resize 時，新創建的 Display.Mode 的 modeId 與 supportedModes 陣列不同步，導致 `DisplayInfo.findMode()` 拋出 `IllegalStateException`。

## 涉及的檔案

1. **VirtualDisplayAdapter.java** - VirtualDisplay resize 邏輯
2. **LogicalDisplay.java** - DisplayInfo 更新邏輯
3. **DisplayDeviceInfo.java** - 設備信息複製邏輯

## Bug 詳細分析

### Bug 1: LogicalDisplay.java - supportedModes 來源錯誤

```java
// 錯誤代碼：從陳舊的 mPrimaryDisplayDeviceInfo 複製 supportedModes
mBaseDisplayInfo.supportedModes = mPrimaryDisplayDeviceInfo != null
        ? mPrimaryDisplayDeviceInfo.supportedModes  // ← 這是舊的！
        : deviceInfo.supportedModes;
mBaseDisplayInfo.modeId = deviceInfo.modeId;  // ← 這是新的 modeId
```

**問題**：`mPrimaryDisplayDeviceInfo` 是上一次更新時緩存的設備信息，在 VirtualDisplay resize 後仍然指向舊的 Mode 陣列（只包含 modeId=1），而 `deviceInfo.modeId` 已經是新的 modeId=2。

### Bug 2: DisplayDeviceInfo.java - 條件複製邏輯

```java
// 錯誤代碼：有條件地保留舊的 supportedModes
supportedModes = (supportedModes.length == other.supportedModes.length)
        ? other.supportedModes : supportedModes;  // ← 長度不同時保留舊的！
```

**問題**：當陣列長度不同時（resize 可能改變 mode 數量），保留舊的 supportedModes 而不是複製新的。

### Bug 3: VirtualDisplayAdapter.java - 操作順序問題

```java
// 錯誤的操作順序
mInfo = null;
sendTraversalRequestLocked();  // ← 在 mInfo 清除後才發送更新請求
```

**問題**：`sendTraversalRequestLocked()` 應該在 `mInfo = null` 之前調用，否則在某些競態條件下，可能會使用緩存的舊 info。

## 完整的數據流問題

```
VirtualDisplay.resize(1280, 720, 240)
    │
    ▼
VirtualDisplayDevice.resizeLocked()
    │ 創建新 Mode: modeId=2, 1280x720
    │ 設置 mInfo = null (清除緩存)
    │
    ▼
sendTraversalRequestLocked()
    │
    ▼
LogicalDisplay.updateLocked(deviceInfo)
    │ deviceInfo.modeId = 2 (新的)
    │ deviceInfo.supportedModes = [Mode{id=2, 1280x720}] (新的)
    │
    │ 但是！
    │ mPrimaryDisplayDeviceInfo.supportedModes = [Mode{id=1, 1920x1080}] (舊的)
    │
    │ 錯誤：複製了舊的 supportedModes
    │ mBaseDisplayInfo.supportedModes = [Mode{id=1}]
    │ mBaseDisplayInfo.modeId = 2
    │
    ▼
應用調用 Display.getMode()
    │
    ▼
DisplayInfo.findMode(modeId=2)
    │ 在 supportedModes=[Mode{id=1}] 中找不到 id=2
    │
    ▼
拋出 IllegalStateException: Unable to locate mode id=2
```

## 修復方案

### Fix 1: LogicalDisplay.java

```java
// 修復：總是從當前的 deviceInfo 複製 supportedModes
mBaseDisplayInfo.modeId = deviceInfo.modeId;
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes, deviceInfo.supportedModes.length);
```

### Fix 2: DisplayDeviceInfo.java

```java
// 修復：無條件複製 supportedModes
supportedModes = other.supportedModes;
```

### Fix 3: VirtualDisplayAdapter.java

```java
// 修復：正確的操作順序
sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
sendTraversalRequestLocked();  // 先發送更新請求
mWidth = width;
mHeight = height;
mMode = createMode(width, height, getRefreshRate());
mDensityDpi = densityDpi;
mInfo = null;  // 最後清除緩存
mPendingChanges |= PENDING_RESIZE;
```

## 學習要點

1. **跨檔案狀態同步**：當多個檔案需要協調更新同一份數據時，必須確保更新順序和數據來源的一致性。

2. **緩存失效問題**：`mPrimaryDisplayDeviceInfo` 是一個緩存引用，在更新邏輯中必須小心不要使用陳舊的緩存數據。

3. **陣列引用 vs 複製**：`Arrays.copyOf()` 創建新陣列，而直接賦值只複製引用。在需要獨立數據時必須使用深複製。

4. **操作順序**：在涉及緩存和事件通知的代碼中，操作順序至關重要。
