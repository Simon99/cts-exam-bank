# Q003: Reprocess Capture 流程錯誤

## CTS 測試失敗現象

執行 CTS 測試 `ReprocessCaptureTest#testReprocessJpeg` 時失敗：

```
FAIL: android.hardware.camera2.cts.ReprocessCaptureTest#testReprocessJpeg

junit.framework.AssertionFailedError: Reprocess capture failed
Error: onCaptureFailed received
Failure reason: CAPTURE_FAILURE_REASON_ERROR
Input image format: YUV_420_888
Output image format: JPEG

Expected: Valid JPEG output
Actual: Capture failed with error

    at android.hardware.camera2.cts.ReprocessCaptureTest.testReprocessJpeg(ReprocessCaptureTest.java:278)
```

## 測試環境
- 相機支援 YUV_REPROCESSING 或 PRIVATE_REPROCESSING
- 成功 capture 了 input YUV image
- 嘗試 reprocess 為 JPEG
- Reprocess capture 失敗

## 重現步驟
1. 執行 `atest ReprocessCaptureTest#testReprocessJpeg`
2. 測試在 reprocess capture 時失敗

## 期望行為
- Reprocess capture 應該成功
- Input image 被重新處理後輸出 JPEG
- onCaptureCompleted 應該被調用

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/ReprocessCaptureTest.java`
- Input configuration 位於 `CameraDeviceImpl.java`
- Reprocess request 處理位於 `CaptureRequest.java`
- Image queue 管理位於 `ImageWriter` 相關類
