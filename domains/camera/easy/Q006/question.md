# Q006: Torch Strength Level 驗證失敗

## CTS 測試失敗現象

執行 CTS 測試 `FlashlightTest#testTurnOnTorchWithStrengthLevel` 時失敗：

```
FAIL: android.hardware.camera2.cts.FlashlightTest#testTurnOnTorchWithStrengthLevel

junit.framework.AssertionFailedError: 
Expected torch strength: 5 (maxLevel)
Actual torch strength: 1

    at android.hardware.camera2.cts.FlashlightTest.testTurnOnTorchWithStrengthLevel(FlashlightTest.java:123)
```

## 測試環境
- 設備支援 torch strength 調整
- FLASH_INFO_STRENGTH_MAXIMUM_LEVEL 報告為 5
- 但 getTorchStrengthLevel() 總是返回 1

## 重現步驟
1. 執行 `atest FlashlightTest#testTurnOnTorchWithStrengthLevel`
2. 測試在驗證 strength level 時失敗

## 期望行為
- turnOnTorchWithStrengthLevel(id, maxLevel) 後
- getTorchStrengthLevel(id) 應該返回 maxLevel
- Strength level 應該和設置的值一致

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/FlashlightTest.java`
- Torch 管理位於 `frameworks/base/core/java/android/hardware/camera2/CameraManager.java`
