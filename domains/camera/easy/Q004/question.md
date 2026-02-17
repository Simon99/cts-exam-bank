# Q004: createCaptureRequest 返回錯誤的 CAPTURE_INTENT

## CTS 測試失敗現象

執行 CTS 測試 `CameraDeviceTest#testCameraDevicePreviewTemplate` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraDeviceTest#testCameraDevicePreviewTemplate

junit.framework.AssertionFailedError: 
Expected: CONTROL_CAPTURE_INTENT_PREVIEW (1)
Actual: CONTROL_CAPTURE_INTENT_STILL_CAPTURE (2)

    at android.hardware.camera2.cts.CameraDeviceTest.captureTemplateTestByCamera(CameraDeviceTest.java:412)
    at android.hardware.camera2.cts.CameraDeviceTest.testCameraDevicePreviewTemplate(CameraDeviceTest.java:175)
```

## 測試環境
- 設備相機正常
- createCaptureRequest(TEMPLATE_PREVIEW) 調用成功
- 但返回的 CaptureRequest 中 CONTROL_CAPTURE_INTENT 不是 PREVIEW

## 重現步驟
1. 執行 `atest CameraDeviceTest#testCameraDevicePreviewTemplate`
2. 測試失敗，CAPTURE_INTENT 值不符合預期

## 期望行為
- createCaptureRequest(TEMPLATE_PREVIEW) 應該返回 CAPTURE_INTENT = PREVIEW
- createCaptureRequest(TEMPLATE_STILL_CAPTURE) 應該返回 CAPTURE_INTENT = STILL_CAPTURE
- Template 和 Intent 應該一一對應

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java`
- Template 處理位於 `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`
