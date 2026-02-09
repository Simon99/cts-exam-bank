# Q004: Session Configuration 驗證失敗

## CTS 測試失敗現象

執行 CTS 測試 `CameraDeviceTest#testSessionConfiguration` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraDeviceTest#testSessionConfiguration

junit.framework.AssertionFailedError: isSessionConfigurationSupported returned false for valid configuration
Configuration: 1920x1080 JPEG output

    at android.hardware.camera2.cts.CameraDeviceTest.testSessionConfiguration(CameraDeviceTest.java:892)
```

## 測試環境
- 相機支援 1920x1080 JPEG 輸出（StreamConfigurationMap 確認）
- 但 isSessionConfigurationSupported() 返回 false
- 實際創建 session 卻成功

## 重現步驟
1. 執行 `atest CameraDeviceTest#testSessionConfiguration`
2. 測試失敗，configuration 驗證不通過

## 期望行為
- isSessionConfigurationSupported() 應該準確反映配置是否支援
- 如果 StreamConfigurationMap 支援該配置，validation 應該返回 true
- Validation 結果和實際 session 創建結果應一致

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java`
- Validation 邏輯位於 `CameraDeviceImpl.java`
- Configuration 檢查涉及 `StreamConfigurationMap`
