# Q005: Repeating Request 停止失敗

## CTS 測試失敗現象

執行 CTS 測試 `CameraDeviceTest#testCameraDeviceRepeatingRequest` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraDeviceTest#testCameraDeviceRepeatingRequest

junit.framework.AssertionFailedError: Repeating request not properly stopped
Expected: onCaptureSequenceAborted or onCaptureSequenceCompleted
Timeout waiting for sequence completion after stopRepeating()

    at android.hardware.camera2.cts.CameraDeviceTest.testCameraDeviceRepeatingRequest(CameraDeviceTest.java:567)
```

## 測試環境
- setRepeatingRequest() 成功
- stopRepeating() 調用無異常
- 但從未收到 onCaptureSequenceCompleted 或 onCaptureSequenceAborted 回調

## 重現步驟
1. 執行 `atest CameraDeviceTest#testCameraDeviceRepeatingRequest`
2. 測試在等待 sequence 完成時超時

## 期望行為
- stopRepeating() 後應該收到 sequence 結束的回調
- 可能是 onCaptureSequenceCompleted 或 onCaptureSequenceAborted
- 回調應該在合理時間內到達

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java`
- Repeating request 管理位於 `CameraDeviceImpl.java`
- Sequence 追蹤位於 `FrameNumberTracker`
