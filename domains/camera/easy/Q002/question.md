# Q002: Flashlight Torch 回調未觸發

## CTS 測試失敗現象

執行 CTS 測試 `FlashlightTest#testSetTorchModeOnOff` 時失敗：

```
FAIL: android.hardware.camera2.cts.FlashlightTest#testSetTorchModeOnOff

org.mockito.exceptions.verification.TooLittleActualInvocations: 
torchListener.onTorchModeChanged("0", true);
Wanted 1 time:
-> at android.hardware.camera2.cts.FlashlightTest.testSetTorchModeOnOff(FlashlightTest.java:178)
But was 0 times.

    at android.hardware.camera2.cts.FlashlightTest.testSetTorchModeOnOff(FlashlightTest.java:178)
```

## 測試環境
- 設備有閃光燈
- setTorchMode(id, true) 調用成功（無異常）
- 但 TorchCallback.onTorchModeChanged() 從未被調用

## 重現步驟
1. 執行 `atest FlashlightTest#testSetTorchModeOnOff`
2. 測試超時失敗，因為等不到 onTorchModeChanged 回調

## 期望行為
- 調用 setTorchMode(id, true) 後，應觸發 onTorchModeChanged(id, true) 回調
- 調用 setTorchMode(id, false) 後，應觸發 onTorchModeChanged(id, false) 回調

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/FlashlightTest.java`
- Framework 回調機制位於 `frameworks/base/core/java/android/hardware/camera2/CameraManager.java`
