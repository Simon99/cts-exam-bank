# Q001: Multi-Camera 邏輯/物理相機交互錯誤

## CTS 測試失敗現象

執行 CTS 測試 `LogicalCameraDeviceTest#testLogicalCameraPhysicalIds` 時失敗：

```
FAIL: android.hardware.camera2.cts.LogicalCameraDeviceTest#testLogicalCameraPhysicalIds

junit.framework.AssertionFailedError: Physical camera results inconsistent with logical camera
Logical camera ID: 0
Physical camera IDs: [2, 3]

Physical camera 2 result LENS_FOCAL_LENGTH: 4.5
Physical camera 3 result LENS_FOCAL_LENGTH: null  <-- Should not be null
Logical camera result LENS_FOCAL_LENGTH: 4.5

    at android.hardware.camera2.cts.LogicalCameraDeviceTest.testLogicalCameraPhysicalIds(LogicalCameraDeviceTest.java:234)
```

## 測試環境
- 設備有 multi-camera（一個邏輯相機包含多個物理相機）
- 邏輯相機 ID 0 對應物理相機 2 和 3
- 請求包含 physical camera request 設置
- 部分物理相機的結果返回 null

## 重現步驟
1. 執行 `atest LogicalCameraDeviceTest#testLogicalCameraPhysicalIds`
2. 測試失敗，物理相機結果不完整

## 期望行為
- 當使用 physical camera request 時
- 每個物理相機都應該返回完整的 CaptureResult
- LENS_FOCAL_LENGTH 等 key 不應該是 null

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/LogicalCameraDeviceTest.java`
- 邏輯相機處理涉及 `CameraDeviceImpl.java`
- 物理相機結果處理涉及 `PhysicalCaptureResultInfo.java`
- Metadata 合併涉及 `CameraMetadataNative.java`
