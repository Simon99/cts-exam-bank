# Q001: Capture 回調順序錯誤

## CTS 測試失敗現象

執行 CTS 測試 `CaptureResultTest#testCameraCaptureResultAllKeys` 時失敗：

```
FAIL: android.hardware.camera2.cts.CaptureResultTest#testCameraCaptureResultAllKeys

junit.framework.AssertionFailedError: onCaptureCompleted received before onCaptureStarted
Frame number: 5
onCaptureStarted timestamp: 0 (never received)
onCaptureCompleted timestamp: 1234567890

    at android.hardware.camera2.cts.CaptureResultTest.validateCaptureResult(CaptureResultTest.java:245)
```

## 測試環境
- Capture 可以正常執行
- 圖像可以正常獲取
- 但 onCaptureStarted 從未被調用
- onCaptureCompleted 正常調用

## 重現步驟
1. 執行 `atest CaptureResultTest#testCameraCaptureResultAllKeys`
2. 測試失敗，回調順序驗證不通過

## 期望行為
- 每個 capture 的回調順序應該是：
  1. onCaptureStarted()
  2. onCaptureProgressed() (如果有 partial results)
  3. onCaptureCompleted()
- onCaptureStarted 必須在 onCaptureCompleted 之前

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CaptureResultTest.java`
- 回調分發位於 `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`
- 回調順序由 `FrameNumberTracker` 管理
