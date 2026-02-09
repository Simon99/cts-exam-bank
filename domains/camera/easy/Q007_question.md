# Q007: ImageReader 格式不支援

## CTS 測試失敗現象

執行 CTS 測試 `ImageReaderTest#testFlexibleYuv` 時失敗：

```
FAIL: android.hardware.camera2.cts.ImageReaderTest#testFlexibleYuv

java.lang.IllegalArgumentException: The image format YUV_420_888 for ImageReader is not supported
    at android.media.ImageReader.nativeInit(Native Method)
    at android.media.ImageReader.<init>(ImageReader.java:180)
    at android.hardware.camera2.cts.ImageReaderTest.testFlexibleYuv(ImageReaderTest.java:112)
```

## 測試環境
- 相機支援 YUV_420_888 格式（從 StreamConfigurationMap 可查）
- 但創建 ImageReader 時拋出異常

## 重現步驟
1. 執行 `atest ImageReaderTest#testFlexibleYuv`
2. 測試在創建 ImageReader 時失敗

## 期望行為
- YUV_420_888 是強制支援的格式
- ImageReader.newInstance(width, height, YUV_420_888, maxImages) 應該成功

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/ImageReaderTest.java`
- 格式驗證位於 `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`
