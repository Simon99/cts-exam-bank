# Q010: Output Surface 配置不支援

## CTS 測試失敗現象

執行 CTS 測試 `CameraDeviceTest#testCreateSession` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraDeviceTest#testCreateSession

android.hardware.camera2.CameraAccessException: CAMERA_ERROR (3): 
Surface configuration not supported
Surface: 1920x1080 JPEG
Error: Output surface format not in supported list

    at android.hardware.camera2.impl.CameraDeviceImpl.createCaptureSession(CameraDeviceImpl.java:623)
    at android.hardware.camera2.cts.CameraDeviceTest.testCreateSession(CameraDeviceTest.java:234)
```

## 測試環境
- 相機支援 1920x1080 JPEG（StreamConfigurationMap 確認）
- 但 createCaptureSession 拋出異常
- 錯誤訊息指出格式不支援

## 重現步驟
1. 執行 `atest CameraDeviceTest#testCreateSession`
2. 測試失敗，session 創建拋出異常

## 期望行為
- 如果 StreamConfigurationMap 報告支援某個配置
- createCaptureSession 應該能成功創建 session
- 不應該拋出 "not supported" 異常

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java`
- Surface 驗證位於 `CameraDeviceImpl.java`
- 格式支援檢查涉及 `SurfaceUtils` 和 `StreamConfigurationMap`
