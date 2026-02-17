# Q006: High Speed Video Recording 幀率不穩定

## CTS 測試失敗現象

執行 CTS 測試 `RecordingTest#testHighSpeedRecording` 時失敗：

```
FAIL: android.hardware.camera2.cts.RecordingTest#testHighSpeedRecording

junit.framework.AssertionFailedError: High speed frame rate unstable
Expected FPS: 240
Actual average FPS: 187.3
Frame timing variance: 23.5ms (max allowed: 5ms)

Frame analysis:
- Total frames: 720
- Expected duration: 3000ms
- Actual duration: 3843ms
- Dropped frames detected: 156

    at android.hardware.camera2.cts.RecordingTest.testHighSpeedRecording(RecordingTest.java:892)
```

## 測試環境
- 設備支援 High Speed Video (240fps)
- High speed session 創建成功
- 但錄製過程幀率不穩定

## 重現步驟
1. 執行 `atest RecordingTest#testHighSpeedRecording`
2. 測試失敗，幀率不達標

## 期望行為
- 高速錄製應該穩定達到 240fps
- 幀間隔應該穩定

## 提示
- High speed session 實現在 `CameraConstrainedHighSpeedCaptureSessionImpl.java`
- Repeating burst 在 `Camera3Device.cpp`
- 幀率控制涉及 HAL 層的 `CameraHardwareInterface`
- 檢查 burst request 的排程邏輯
