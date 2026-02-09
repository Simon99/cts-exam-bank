# Q001 答案：Multi-Camera 邏輯/物理相機交互錯誤

## 問題根因

在物理相機結果處理流程中，第二個物理相機的 metadata 沒有被正確解析。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
private void processPhysicalCameraResults(PhysicalCaptureResultInfo[] physicalResults) {
    for (int i = 0; i < physicalResults.length; i++) {
        // BUG: 只處理第一個物理相機
        if (i > 0) {
            continue;  // 跳過其他物理相機
        }
        processPhysicalResult(physicalResults[i]);
    }
}
```

**文件 2：** `frameworks/base/core/java/android/hardware/camera2/impl/PhysicalCaptureResultInfo.java`

```java
public CameraMetadataNative getCameraMetadataNative() {
    // BUG: 在某些情況下返回 null
    if (mPhysicalCameraId.equals("3")) {
        return null;  // 錯誤：特定 ID 返回 null
    }
    return mCameraMetadata;
}
```

**文件 3：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
// Metadata 合併時沒有處理 null 情況
```

## 修復方法

```java
// CameraDeviceImpl.java
private void processPhysicalCameraResults(PhysicalCaptureResultInfo[] physicalResults) {
    for (int i = 0; i < physicalResults.length; i++) {
        // 處理所有物理相機的結果
        processPhysicalResult(physicalResults[i]);
    }
}

// PhysicalCaptureResultInfo.java
public CameraMetadataNative getCameraMetadataNative() {
    // 始終返回 metadata，不做特殊處理
    return mCameraMetadata;
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest LogicalCameraDeviceTest#testLogicalCameraPhysicalIds`
4. 測試應該通過

## 學習重點
- Multi-camera 是 Android 複雜的相機功能
- 邏輯相機和物理相機的結果處理需要協調
- 循環中的 continue/break 語句是常見 bug 來源
