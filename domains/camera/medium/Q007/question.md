# Q007: AE Mode 設置無效

## CTS 測試失敗現象

執行 CTS 測試 `CaptureRequestTest#testAeModeAndLock` 時失敗：

```
FAIL: android.hardware.camera2.cts.CaptureRequestTest#testAeModeAndLock

junit.framework.AssertionFailedError: AE mode not applied
Requested: CONTROL_AE_MODE_ON (1)
Result: CONTROL_AE_MODE_OFF (0)

    at android.hardware.camera2.cts.CaptureRequestTest.testAeModeAndLock(CaptureRequestTest.java:892)
```

## 測試環境
- 相機支援 AUTO exposure
- 在 CaptureRequest 設置 CONTROL_AE_MODE_ON
- CaptureResult 返回 CONTROL_AE_MODE_OFF

## 重現步驟
1. 執行 `atest CaptureRequestTest#testAeModeAndLock`
2. 測試失敗，AE mode 不符合設置

## 期望行為
- CaptureRequest 中設置的 CONTROL_AE_MODE 應該被正確應用
- CaptureResult 應該反映實際的 AE mode
- Request 和 Result 的 AE mode 應該一致（除非設備不支援）

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CaptureRequestTest.java`
- Request 處理位於 `CameraDeviceImpl.java`
- Metadata 設置位於 `CameraMetadataNative.java`
