# Q005: Multi-Camera Logical Stream 配置失敗

## CTS 測試失敗現象

執行 CTS 測試 `CameraDeviceTest#testMultiCameraLogicalStreaming` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraDeviceTest#testMultiCameraLogicalStreaming

java.lang.AssertionError: Logical camera stream configuration failed
Physical camera ID: 2
Expected stream state: CONFIGURED
Actual stream state: ERROR

Configuration details:
- Logical camera ID: 0
- Physical camera IDs: [1, 2]
- Stream configuration: YUV_420_888 @ 1920x1080

Error: Physical stream 2 failed to configure while stream 1 succeeded
    at android.hardware.camera2.cts.CameraDeviceTest.testMultiCameraLogicalStreaming(CameraDeviceTest.java:1523)
```

## 測試環境
- 設備支援 Multi-Camera (logical camera)
- 有至少兩個 physical camera
- Logical camera 在 camera list 中

## 重現步驟
1. 執行 `atest CameraDeviceTest#testMultiCameraLogicalStreaming`
2. 測試失敗，部分 physical stream 配置失敗

## 期望行為
- 所有 physical camera streams 都應成功配置
- Logical camera 應正確協調所有 physical streams

## 提示
- 測試涉及 `CameraDeviceTest.java`
- Logical camera 實現在 `LogicalCameraDeviceTracker.java`
- Stream 配置在 `Camera3Device.cpp` 和 `Camera3StreamInterface.h`
- 注意 physical camera 同步配置邏輯
