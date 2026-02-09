# Q002 - 解答

## Bug 位置

`frameworks/base/services/core/java/com/android/server/display/LocalDisplayAdapter.java`

第 325 行

## 原始代碼

```java
boolean isAlternative = j != i && other.width == mode.width
        && other.height == mode.height
        && other.peakRefreshRate != mode.peakRefreshRate
        && other.group == mode.group;
```

## Bug 代碼

```java
boolean isAlternative = j != i && other.width == mode.width
        && other.height == mode.height
        && other.peakRefreshRate > mode.peakRefreshRate  // BUG: > 取代 !=
        && other.group == mode.group;
```

## 原因分析

`LocalDisplayAdapter` 負責計算每個顯示模式的 alternative refresh rates。原本的邏輯是：如果兩個模式分辨率相同但刷新率不同，則互為 alternative。

Bug 將 `!=` 改成 `>`，導致只有刷新率更高的模式會被加入 alternative 列表。這破壞了對稱性：
- 60Hz 的 alternative 會包含 90Hz、120Hz
- 但 90Hz 的 alternative **不會**包含 60Hz

CTS 測試檢查這個對稱性，所以會失敗。

## 修復方式

將 `>` 改回 `!=`，恢復雙向的 alternative 關係。

## 調用鏈

```
Display.getSupportedModes()
  → DisplayInfo.supportedModes
    → LogicalDisplay.updateDisplayInfoLocked()
      → DisplayDeviceInfo.supportedModes
        → LocalDisplayAdapter.updateDisplayModesLocked()  ← Bug 在這裡
```

## 為什麼不會 Bootloop

這個 bug 只影響 `getAlternativeRefreshRates()` 的返回值，不影響核心的模式切換功能。系統仍然可以正常選擇和切換顯示模式。
