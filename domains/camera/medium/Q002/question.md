# Q002: Partial Result Count 不一致

## CTS 測試失敗現象

執行 CTS 測試 `CaptureResultTest#testPartialResult` 時失敗：

```
FAIL: android.hardware.camera2.cts.CaptureResultTest#testPartialResult

junit.framework.AssertionFailedError: Number of partial results exceeds maximum
Expected partial result count: <= 3
Actual partial results received: 5

    at android.hardware.camera2.cts.CaptureResultTest.testPartialResult(CaptureResultTest.java:198)
```

## 測試環境
- REQUEST_PARTIAL_RESULT_COUNT 報告為 3
- 但實際收到的 partial results 數量超過 3

## 重現步驟
1. 執行 `atest CaptureResultTest#testPartialResult`
2. 測試失敗，partial result 數量不符

## 期望行為
- REQUEST_PARTIAL_RESULT_COUNT 定義了最大 partial result 數量
- 實際收到的 partial results 數量不應超過此值
- Partial results 中的 key 不應重複

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CaptureResultTest.java`
- Partial result 處理位於 `CameraDeviceImpl.java`
- Count 定義位於 `CameraCharacteristics`
