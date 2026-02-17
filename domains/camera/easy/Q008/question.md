# Q008: Preview Size 列表為空

## CTS 測試失敗現象

執行 CTS 測試 `SurfaceViewPreviewTest#testCameraPreview` 時失敗：

```
FAIL: android.hardware.camera2.cts.SurfaceViewPreviewTest#testCameraPreview

java.lang.ArrayIndexOutOfBoundsException: length=0; index=0
    at android.hardware.camera2.cts.SurfaceViewPreviewTest.previewTestByCamera(SurfaceViewPreviewTest.java:245)
    at android.hardware.camera2.cts.SurfaceViewPreviewTest.testCameraPreview(SurfaceViewPreviewTest.java:92)
```

## 測試環境
- 相機可以正常開啟
- 但 getOutputSizes(SurfaceHolder.class) 返回空陣列

## 重現步驟
1. 執行 `atest SurfaceViewPreviewTest#testCameraPreview`
2. 測試在獲取 preview size 時失敗

## 期望行為
- StreamConfigurationMap.getOutputSizes(SurfaceHolder.class) 應該返回支援的 preview sizes
- 至少應該有一個支援的 size

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/SurfaceViewPreviewTest.java`
- Size 查詢位於 `frameworks/base/core/java/android/hardware/camera2/params/StreamConfigurationMap.java`
