# Q006: Focus Distance 超出範圍

## CTS 測試失敗現象

執行 CTS 測試 `CaptureRequestTest#testFocusDistanceControl` 時失敗：

```
FAIL: android.hardware.camera2.cts.CaptureRequestTest#testFocusDistanceControl

junit.framework.AssertionFailedError: Focus distance out of valid range
Requested focus distance: 0.5
Result focus distance: 10.0
Valid range: [0.0, 1.0]

    at android.hardware.camera2.cts.CaptureRequestTest.testFocusDistanceControl(CaptureRequestTest.java:1567)
```

## 測試環境
- 相機支援 MANUAL_SENSOR capability
- LENS_INFO_MINIMUM_FOCUS_DISTANCE 報告為 1.0
- 設置 LENS_FOCUS_DISTANCE = 0.5
- 但結果返回 10.0，超出有效範圍

## 重現步驟
1. 執行 `atest CaptureRequestTest#testFocusDistanceControl`
2. 測試失敗，focus distance 範圍驗證不通過

## 期望行為
- LENS_FOCUS_DISTANCE 應該在 [0, MINIMUM_FOCUS_DISTANCE] 範圍內
- 設置的值和結果返回的值應該相近
- 不應該返回超出範圍的值

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CaptureRequestTest.java`
- Focus distance 處理涉及 `CameraMetadataNative.java`
- 範圍定義在 `CameraCharacteristics`
