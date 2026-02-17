# Q003: Camera Availability 回調不一致

## CTS 測試失敗現象

執行 CTS 測試 `CameraManagerTest#testCameraManagerAvailabilityCallback` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraManagerTest#testCameraManagerAvailabilityCallback

junit.framework.AssertionFailedError: Camera availability mismatch
Camera "0" reported as unavailable, but can still be opened successfully

    at android.hardware.camera2.cts.CameraManagerTest.testCameraManagerAvailabilityCallback(CameraManagerTest.java:342)
```

## 測試環境
- 相機正常
- AvailabilityCallback 報告 camera unavailable
- 但實際上 openCamera() 可以成功

## 重現步驟
1. 執行 `atest CameraManagerTest#testCameraManagerAvailabilityCallback`
2. 測試失敗，availability 狀態不一致

## 期望行為
- onCameraAvailable() 表示相機可以開啟
- onCameraUnavailable() 表示相機被佔用或斷開
- Availability 狀態應該和實際可開啟性一致

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraManagerTest.java`
- Availability 管理位於 `CameraManager.java` 和 `CameraManagerGlobal`
