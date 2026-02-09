# Q005 答案：CaptureResult Timestamp 為負數

## 問題根因

在 `CameraDeviceImpl.java` 的 CaptureResult 處理邏輯中，timestamp 被錯誤地設為負值。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
private void onCaptureResultReceived(CameraMetadataNative result, 
        CaptureResultExtras resultExtras) {
    // BUG: 強制設置負數 timestamp
    long timestamp = result.get(CaptureResult.SENSOR_TIMESTAMP);
    result.set(CaptureResult.SENSOR_TIMESTAMP, -1000000000L);  // 錯誤！
    
    // ... 繼續處理 result
}
```

## 修復方法

```java
private void onCaptureResultReceived(CameraMetadataNative result, 
        CaptureResultExtras resultExtras) {
    // 不要修改原始的 timestamp
    // 移除對 SENSOR_TIMESTAMP 的錯誤設置
    
    // ... 繼續處理 result
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest SurfaceViewPreviewTest#testCameraPreview`
4. 測試應該通過

## 學習重點
- SENSOR_TIMESTAMP 是每個 CaptureResult 的必要屬性
- Timestamp 必須是正數且單調遞增
- 任何對 metadata 的錯誤修改都會導致 CTS 失敗
