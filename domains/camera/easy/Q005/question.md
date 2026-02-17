# Q005: CaptureResult Timestamp 為負數

## CTS 測試失敗現象

執行 CTS 測試 `SurfaceViewPreviewTest#testCameraPreview` 時失敗：

```
FAIL: android.hardware.camera2.cts.SurfaceViewPreviewTest#testCameraPreview

junit.framework.AssertionFailedError: Timestamp should be positive
Expected: >= 0
Actual: -1000000000

    at android.hardware.camera2.cts.SurfaceViewPreviewTest.validateCaptureResult(SurfaceViewPreviewTest.java:298)
    at android.hardware.camera2.cts.SurfaceViewPreviewTest.testCameraPreview(SurfaceViewPreviewTest.java:95)
```

## 測試環境
- Preview 正常顯示
- CaptureResult 可以正常獲取
- 但 SENSOR_TIMESTAMP 返回負值

## 重現步驟
1. 執行 `atest SurfaceViewPreviewTest#testCameraPreview`
2. 測試失敗，timestamp 驗證不通過

## 期望行為
- SENSOR_TIMESTAMP 應該是正數，代表 capture 時的 nanoseconds timestamp
- Timestamp 應該是單調遞增的

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/SurfaceViewPreviewTest.java`
- CaptureResult 處理位於 `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`
