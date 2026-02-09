# Q008: Frame Duration 計算錯誤

## CTS 測試失敗現象

執行 CTS 測試 `SurfaceViewPreviewTest#testPreviewFpsRange` 時失敗：

```
FAIL: android.hardware.camera2.cts.SurfaceViewPreviewTest#testPreviewFpsRange

junit.framework.AssertionFailedError: Frame duration outside expected range
Expected FPS range: [15, 30]
Expected frame duration: 33333333ns - 66666666ns
Actual frame duration: 100000000ns (10 FPS)

    at android.hardware.camera2.cts.SurfaceViewPreviewTest.testPreviewFpsRange(SurfaceViewPreviewTest.java:278)
```

## 測試環境
- 設置 AE_TARGET_FPS_RANGE = [15, 30]
- 但實際 frame duration 對應約 10 FPS
- SENSOR_FRAME_DURATION 報告的值不符合 FPS 設置

## 重現步驟
1. 執行 `atest SurfaceViewPreviewTest#testPreviewFpsRange`
2. 測試失敗，frame duration 不在預期範圍

## 期望行為
- FPS range [15, 30] 對應 frame duration 33.3ms - 66.6ms
- SENSOR_FRAME_DURATION 應該在此範圍內
- Duration 和 FPS 應該數學上一致

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/SurfaceViewPreviewTest.java`
- Frame duration 處理位於 `CameraMetadataNative.java`
- FPS/Duration 轉換涉及 `CameraDeviceImpl.java`
