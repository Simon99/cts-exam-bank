# M-Q004: BrightnessConfiguration 曲線不一致

## 問題描述

你收到一份 CTS 測試報告，顯示 `CtsDisplayTestCases` 中亮度配置相關的測試失敗：

```
FAILURE: android.display.cts.BrightnessTest#testSetAndGetBrightnessConfiguration
junit.framework.AssertionFailedError: Brightness configuration curve mismatch
Expected curve: lux=[0.0, 100.0, 1000.0], nits=[10.0, 200.0, 500.0]
Actual curve: lux=[10.0, 200.0, 500.0], nits=[0.0, 100.0, 1000.0]

=============== Summary ===============
PASSED            : 94
FAILED            : 2
```

測試用 `setBrightnessConfiguration()` 設定了一條亮度曲線，但隨後用 `getBrightnessConfiguration()` 取回的曲線數值對調了。

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.BrightnessTest#testSetAndGetBrightnessConfiguration -s <device_serial>
```

## 任務

1. 分析為什麼設定和取回的曲線數值會對調
2. 找出 bug 的位置
3. 提供修復方案

## 提示

- 設定 API 沒有報錯，問題出在存取過程
- 注意陣列參數的順序
- 追蹤 set 和 get 路徑中的數據處理

## 難度

Medium（需要在 set/get 路徑加 log 追蹤數據流）

## 時間限制

25 分鐘
