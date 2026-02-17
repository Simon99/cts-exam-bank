# Q004: Extension Session 初始化失敗

## CTS 測試失敗現象

執行 CTS 測試 `CameraExtensionSessionTest#testExtensionSession` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraExtensionSessionTest#testExtensionSession

junit.framework.AssertionFailedError: Extension session creation failed
Extension type: EXTENSION_NIGHT
Error: onConfigureFailed received instead of onConfigured

StateCallback sequence:
1. onConfigureStarted - OK
2. onConfigureFailed - ERROR (should be onConfigured)

    at android.hardware.camera2.cts.CameraExtensionSessionTest.testExtensionSession(CameraExtensionSessionTest.java:189)
```

## 測試環境
- 設備支援 Camera Extensions
- EXTENSION_NIGHT 在 supported extensions 列表中
- Session 配置開始正常
- 但 configuration 最終失敗

## 重現步驟
1. 執行 `atest CameraExtensionSessionTest#testExtensionSession`
2. 測試失敗，extension session 配置失敗

## 期望行為
- Extension session 配置應該成功
- 應該收到 onConfigured 回調
- Extension 功能應該可用

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraExtensionSessionTest.java`
- Extension session 位於 `CameraExtensionSessionImpl.java`
- Extension characteristics 位於 `CameraExtensionCharacteristics.java`
- 配置驗證涉及 `CameraDeviceImpl.java`
