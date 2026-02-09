# CTS Hard Q006: Brightness Zone Thermal Refresh Rate 配置錯誤（多檔案交互）

## 難度：Hard (多檔案交互)

## 問題描述

在 Android Display 系統中，當設備處於 **Low Brightness Zone**（低亮度區域）時，系統會根據當前的 **Thermal Throttling 狀態** 來調整 Refresh Rate。然而，使用者報告在低亮度且設備發熱時，螢幕仍然保持高刷新率，導致：
- 電池消耗異常增加
- 設備在高溫下無法有效降低刷新率
- 與 High Brightness Zone 的行為不一致

## 復現步驟

1. 設置設備進入低亮度環境（brightness < 0.2）
2. 透過壓力測試或持續使用讓設備進入 Thermal Throttling 狀態（THROTTLING_MODERATE 或更高）
3. 觀察 Refresh Rate 的變化
4. **預期：** 在 Low Zone + Thermal Throttling 時，Refresh Rate 應該降低（例如降到 60Hz）
5. **實際：** Refresh Rate 沒有正確降低，或者使用了錯誤的限制範圍

## 涉及的 CTS 測試

```bash
adb shell am instrument -w -e class android.display.cts.RefreshRateTest \
    android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

## 涉及的源代碼檔案

1. **DisplayModeDirector.java** (`services/core/java/com/android/server/display/mode/`)
   - `BrightnessObserver` 內部類
   - `onBrightnessChangedLocked()` 方法 - 根據 brightness 和 thermal 狀態決定 refresh rate

2. **SkinThermalStatusObserver.java** (`services/core/java/com/android/server/display/mode/`)
   - `findBestMatchingRefreshRateRange()` 靜態方法 - 根據 thermal status 查找對應的 refresh rate 範圍

3. **DisplayDeviceConfig.java** (`services/core/java/com/android/server/display/`)
   - `getLowBlockingZoneThermalMap()` - 返回 Low Zone 的 thermal refresh rate 配置
   - `getHighBlockingZoneThermalMap()` - 返回 High Zone 的 thermal refresh rate 配置

## 調用鏈分析要點

1. `BrightnessObserver.onDisplayChanged()` 接收 brightness 變化
2. 調用 `onBrightnessChangedLocked()` 判斷當前是否在 low/high zone
3. 如果在 low zone 且有 thermal throttling，使用 `mLowZoneRefreshRateForThermals` 查找限制
4. 調用 `SkinThermalStatusObserver.findBestMatchingRefreshRateRange()` 獲取對應的 refresh rate 範圍
5. 設置 refresh rate vote

## 技術背景

- **Low Zone**: 低亮度區域，通常需要較低的 refresh rate 以節省電力，且在 thermal throttling 時需要更積極的限制
- **High Zone**: 高亮度區域，通常需要較高的 refresh rate 以獲得更好的視覺體驗
- **Thermal Map**: 不同的 zone 有不同的 thermal 配置，Low Zone 的限制通常比 High Zone 更嚴格

## 答題要求

1. 找出 bug 所在的檔案和具體行數
2. 說明為什麼 Low Zone 的 Thermal Refresh Rate 沒有正確應用
3. 解釋這個 bug 如何影響多個組件的交互
4. 提供修復方案

## 提示

問題可能是一個典型的 **copy-paste 錯誤**，在處理相似邏輯時使用了錯誤的變數。
