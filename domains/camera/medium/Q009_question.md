# Q009: Zoom Ratio 驗證失敗

## CTS 測試失敗現象

執行 CTS 測試 `CaptureRequestTest#testDigitalZoom` 時失敗：

```
FAIL: android.hardware.camera2.cts.CaptureRequestTest#testDigitalZoom

junit.framework.AssertionFailedError: Zoom ratio not applied correctly
Requested zoom ratio: 2.0
Result zoom ratio: 1.0
Expected crop region based on zoom: [480, 270, 1440, 810]
Actual crop region: [0, 0, 1920, 1080]

    at android.hardware.camera2.cts.CaptureRequestTest.testDigitalZoom(CaptureRequestTest.java:1823)
```

## 測試環境
- 相機支援 ZOOM_RATIO control
- 設置 CONTROL_ZOOM_RATIO = 2.0
- 但結果顯示 zoom 未生效

## 重現步驟
1. 執行 `atest CaptureRequestTest#testDigitalZoom`
2. 測試失敗，zoom ratio 和 crop region 不一致

## 期望行為
- 設置 ZOOM_RATIO = 2.0 應該使視野變為 1/2
- SCALER_CROP_REGION 應該反映 zoom 效果
- Request 和 Result 的 zoom ratio 應該一致

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CaptureRequestTest.java`
- Zoom 處理涉及 `CameraMetadataNative.java`
- Crop region 計算涉及 `CameraDeviceImpl.java`
