# Q008: RAW Capture DNG Metadata 不完整

## CTS 測試失敗現象

執行 CTS 測試 `StillCaptureTest#testRawCapture` 時失敗：

```
FAIL: android.hardware.camera2.cts.StillCaptureTest#testRawCapture

junit.framework.AssertionFailedError: DNG metadata validation failed

Missing mandatory DNG tags:
- ColorMatrix1 (0xc621): NOT FOUND
- CalibrationIlluminant1 (0xc65a): NOT FOUND
- AsShotNeutral (0xc628): NOT FOUND

Present tags: 45/52 mandatory tags found
DNG Version: 1.4
Image dimensions: 4032x3024

DngCreator validation: FAILED
    at android.hardware.camera2.cts.StillCaptureTest.validateDngMetadata(StillCaptureTest.java:567)
    at android.hardware.camera2.cts.StillCaptureTest.testRawCapture(StillCaptureTest.java:234)
```

## 測試環境
- 設備支援 RAW capture
- DNG 文件可以生成
- 但某些 metadata tag 缺失

## 重現步驟
1. 執行 `atest StillCaptureTest#testRawCapture`
2. 測試失敗，DNG metadata 不完整

## 期望行為
- DNG 文件應包含所有必要的 metadata tags
- ColorMatrix、Illuminant 等 calibration 資訊應完整

## 提示
- DNG 創建在 `DngCreator.java`
- Metadata 來自 `CameraCharacteristics` 和 `CaptureResult`
- Native 層實現在 `DngCreator.cpp`
- 檢查 tag 寫入邏輯和 characteristics 查詢
