# Q010: Camera Flash Torch Mode 狀態不同步

## CTS 測試失敗現象

執行 CTS 測試 `CameraManagerTest#testTorchCallback` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraManagerTest#testTorchCallback

junit.framework.AssertionFailedError: Torch state callback mismatch

Action: setTorchMode(cameraId="0", enabled=true)
Expected callback: onTorchModeChanged(cameraId="0", enabled=true)
Actual callback: onTorchModeChanged(cameraId="0", enabled=false)

State sequence:
1. setTorchMode(true) - returned successfully
2. onTorchModeChanged(false) - incorrect!
3. setTorchMode(false) - returned successfully
4. onTorchModeChanged(false) - OK but should have received true first

Internal state: enabled=true
Reported state: enabled=false
    at android.hardware.camera2.cts.CameraManagerTest.testTorchCallback(CameraManagerTest.java:567)
```

## 測試環境
- 設備有 flash 硬體
- Torch mode 可用

## 重現步驟
1. 執行 `atest CameraManagerTest#testTorchCallback`
2. 測試失敗，torch 狀態報告錯誤

## 期望行為
- setTorchMode 後應收到正確狀態的 callback
- 內部狀態和報告狀態應一致

## 提示
- Torch 控制在 `CameraManager.java` 和 `CameraServiceProxy.java`
- 狀態追蹤在 `CameraManagerGlobal.java`
- Service 層在 `CameraService.cpp`
- 注意狀態更新和 callback 的時序
