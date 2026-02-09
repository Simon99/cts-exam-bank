# Q006 提示

## 提示 1 - 問題範圍
Bug 位於 `DisplayModeDirector.java` 的 `BrightnessObserver.onBrightnessChangedLocked()` 方法中。

## 提示 2 - 邏輯流程
注意 `insideLowZone` 和 `insideHighZone` 兩個分支的處理邏輯。這兩個分支結構非常相似，但使用的變數應該不同。

## 提示 3 - 變數名稱
檢查以下兩個成員變數：
- `mLowZoneRefreshRateForThermals` - Low Zone 的 thermal refresh rate 配置
- `mHighZoneRefreshRateForThermals` - High Zone 的 thermal refresh rate 配置

這兩個變數是否在正確的地方被使用？

## 提示 4 - 具體位置
在 `insideLowZone` 分支中，調用 `SkinThermalStatusObserver.findBestMatchingRefreshRateRange()` 時，檢查傳入的 thermal map 參數是否正確。

## 調試方法
1. 使用 `adb shell dumpsys display` 查看當前的 refresh rate vote
2. 檢查 `BrightnessObserver` 的 dump 輸出，比較 low zone 和 high zone 的 thermal map 配置
3. 在低亮度環境下，模擬 thermal throttling 並觀察 refresh rate 變化
