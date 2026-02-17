# Q009: CaptureRequest 批量提交 Ordering 錯亂

## CTS 測試失敗現象

執行 CTS 測試 `BurstCaptureTest#testBurstCaptureOrdering` 時失敗：

```
FAIL: android.hardware.camera2.cts.BurstCaptureTest#testBurstCaptureOrdering

junit.framework.AssertionFailedError: Capture results out of order

Submitted request sequence: [1, 2, 3, 4, 5, 6, 7, 8]
Received result sequence:   [1, 3, 2, 4, 6, 5, 8, 7]

Request frame numbers vs Result frame numbers:
- Request 2: frame 102 -> Result received after Request 3 (frame 103)
- Request 5: frame 105 -> Result received after Request 6 (frame 106)

Ordering violations: 4/8 results out of order
    at android.hardware.camera2.cts.BurstCaptureTest.testBurstCaptureOrdering(BurstCaptureTest.java:234)
```

## 測試環境
- Burst capture 模式
- 連續提交多個 request

## 重現步驟
1. 執行 `atest BurstCaptureTest#testBurstCaptureOrdering`
2. 測試失敗，結果順序錯亂

## 期望行為
- Capture 結果應按照 request 提交順序返回
- Frame number 順序應該一致

## 提示
- Request queue 管理在 `RequestThread.java`
- 結果分發在 `CameraDeviceImpl.java`
- Native 層排隊在 `Camera3Device.cpp`
- 注意多線程的 result callback 順序
