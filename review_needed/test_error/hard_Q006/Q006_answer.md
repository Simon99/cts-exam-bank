# Q006 答案解析

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/mode/DisplayModeDirector.java`

**類別**: `BrightnessObserver` 內部類

**方法**: `onBrightnessChangedLocked()`

**行號**: 約 2156 行

## Bug 描述

在 `onBrightnessChangedLocked()` 方法中，當設備處於 **Low Brightness Zone** 且有 Thermal Throttling 時，錯誤地使用了 `mHighZoneRefreshRateForThermals` 而不是正確的 `mLowZoneRefreshRateForThermals`。

### 錯誤代碼

```java
boolean insideLowZone = hasValidLowZone() && isInsideLowZone(mBrightness, mAmbientLux);
if (insideLowZone) {
    refreshRateVote =
            Vote.forPhysicalRefreshRates(mRefreshRateInLowZone, mRefreshRateInLowZone);
    if (mLowZoneRefreshRateForThermals != null) {
        RefreshRateRange range = SkinThermalStatusObserver
                .findBestMatchingRefreshRateRange(mThermalStatus,
                        mHighZoneRefreshRateForThermals);  // <-- BUG: 應該是 mLowZoneRefreshRateForThermals
        if (range != null) {
            refreshRateVote =
                    Vote.forPhysicalRefreshRates(range.min, range.max);
        }
    }
    ...
}
```

## 多檔案交互分析

### 涉及的檔案和組件

1. **DisplayModeDirector.java (BrightnessObserver)**
   - 負責根據 brightness 和 thermal 狀態決定 refresh rate vote
   - 使用 `mLowZoneRefreshRateForThermals` 和 `mHighZoneRefreshRateForThermals`

2. **SkinThermalStatusObserver.java**
   - 提供 `findBestMatchingRefreshRateRange()` 靜態方法
   - 根據 thermal status 從配置 map 中查找對應的 refresh rate 範圍

3. **DisplayDeviceConfig.java**
   - 提供 `getLowBlockingZoneThermalMap()` 和 `getHighBlockingZoneThermalMap()`
   - 兩個 map 通常有不同的配置：
     - Low Zone: 更嚴格的限制（例如 THROTTLING_MODERATE 時降到 60Hz）
     - High Zone: 較寬鬆的限制（例如只在 THROTTLING_SEVERE 時才降低）

### 交互流程

```
Thermal Event → BrightnessThermalClamper → Brightness 變化
                                              ↓
                                    DisplayListener.onDisplayChanged()
                                              ↓
                              BrightnessObserver.onBrightnessChangedLocked()
                                              ↓
                              SkinThermalStatusObserver.findBestMatchingRefreshRateRange()
                                              ↓
                                    VotesStorage.updateGlobalVote()
```

## Bug 影響

1. **電池消耗增加**: 在低亮度環境下，設備仍然使用高刷新率
2. **Thermal 管理失效**: High Zone 的 thermal 配置通常更寬鬆，導致設備在高溫時無法有效降低刷新率
3. **行為不一致**: Low Zone 和 High Zone 的 thermal 行為不符合設計預期

## 修復方案

```java
if (insideLowZone) {
    refreshRateVote =
            Vote.forPhysicalRefreshRates(mRefreshRateInLowZone, mRefreshRateInLowZone);
    if (mLowZoneRefreshRateForThermals != null) {
        RefreshRateRange range = SkinThermalStatusObserver
                .findBestMatchingRefreshRateRange(mThermalStatus,
                        mLowZoneRefreshRateForThermals);  // 修正為 mLowZoneRefreshRateForThermals
        if (range != null) {
            refreshRateVote =
                    Vote.forPhysicalRefreshRates(range.min, range.max);
        }
    }
    ...
}
```

## 根本原因分析

這是一個典型的 **copy-paste 錯誤**。開發者在實現 `insideLowZone` 分支時，可能是從 `insideHighZone` 分支複製代碼後修改，但忘記將 `mHighZoneRefreshRateForThermals` 改為 `mLowZoneRefreshRateForThermals`。

## 驗證方法

1. 使用 `adb shell dumpsys display` 檢查 refresh rate votes
2. 在低亮度環境下模擬 thermal throttling，驗證 refresh rate 是否正確降低
3. 比較修復前後的 `PRIORITY_FLICKER_REFRESH_RATE` vote
