# Q007: Camera2 Session 切換時 Surface 狀態錯誤

## CTS 測試失敗現象

執行 CTS 測試 `CameraDeviceTest#testSessionSwitching` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraDeviceTest#testSessionSwitching

java.lang.IllegalStateException: Surface was abandoned
Surface: android.view.Surface@a1b2c3d4
State: ABANDONED (expected: READY)

Session transition log:
1. Session A created - OK
2. Session A capturing - OK
3. Session B creation started
4. Session A surfaces abandoned (premature!)
5. Session B failed to configure

java.lang.IllegalStateException: Cannot configure session with abandoned surfaces
    at android.hardware.camera2.impl.CameraDeviceImpl.createCaptureSession(CameraDeviceImpl.java:567)
    at android.hardware.camera2.cts.CameraDeviceTest.testSessionSwitching(CameraDeviceTest.java:1823)
```

## 測試環境
- 連續切換 capture session
- 兩個 session 使用部分相同的 Surface

## 重現步驟
1. 執行 `atest CameraDeviceTest#testSessionSwitching`
2. 測試失敗，Surface 過早被 abandon

## 期望行為
- Session 切換時應該正確管理 Surface 生命週期
- 新 session 配置完成前不應 abandon 舊 Surface

## 提示
- Session 狀態管理在 `CameraCaptureSessionImpl.java`
- Surface 管理在 `OutputConfiguration.java` 和 `Camera3Device.cpp`
- Session 切換涉及 `CameraDeviceImpl.java` 的狀態機
- 注意 Surface 共享時的生命週期
