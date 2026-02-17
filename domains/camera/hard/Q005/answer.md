# Q005 答案：Multi-Camera Logical Stream 配置失敗

## 問題根因

Logical camera 配置 physical streams 時，第二個 physical camera 的配置請求被錯誤地跳過。

## Bug 位置

**文件 1：** `frameworks/av/services/camera/libcameraservice/device3/Camera3Device.cpp`

```cpp
status_t Camera3Device::configureStreamsLocked(
        const StreamConfiguration& config, bool isReconfigure) {
    // BUG: 迴圈使用錯誤的索引
    for (size_t i = 0; i < config.streams.size(); i++) {
        if (config.streams[i].physicalCameraId.size() > 0) {
            // 只處理第一個 physical camera
            if (i > 0) continue;  // 錯誤：跳過後續 physical streams
            configurePhysicalStream(config.streams[i]);
        }
    }
}
```

**文件 2：** `frameworks/av/services/camera/libcameraservice/api2/CameraDeviceClient.cpp`

```cpp
binder::Status CameraDeviceClient::submitRequestList(...) {
    // BUG: physical camera ID 映射錯誤
    for (const auto& request : requests) {
        auto physicalId = request.physicalCameraId;
        if (!physicalId.empty()) {
            // 使用錯誤的 map 查找
            auto it = mPhysicalCameraMap.find(physicalId);
            if (it == mPhysicalCameraMap.end()) {
                // 第二個 physical camera 找不到
            }
        }
    }
}
```

**文件 3：** `frameworks/av/services/camera/libcameraservice/common/CameraProviderManager.cpp`

```cpp
// Physical camera 資訊初始化
status_t CameraProviderManager::initializeLogicalCamera(...) {
    // BUG: 只初始化第一個 physical camera 的資訊
    if (mPhysicalCameras.empty()) {
        mPhysicalCameras.push_back(physicalCameraIds[0]);
        // 缺少其他 physical cameras
    }
}
```

## 修復方法

```cpp
// Camera3Device.cpp
status_t Camera3Device::configureStreamsLocked(...) {
    for (size_t i = 0; i < config.streams.size(); i++) {
        if (config.streams[i].physicalCameraId.size() > 0) {
            // 正確處理所有 physical streams
            configurePhysicalStream(config.streams[i]);
        }
    }
}

// CameraProviderManager.cpp
status_t CameraProviderManager::initializeLogicalCamera(...) {
    // 初始化所有 physical cameras
    for (const auto& id : physicalCameraIds) {
        mPhysicalCameras.push_back(id);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 camera service
3. 執行 `atest CameraDeviceTest#testMultiCameraLogicalStreaming`
4. 測試應該通過

## 學習重點
- Multi-camera 架構涉及 logical 和 physical camera 的協調
- Stream 配置必須處理所有 physical cameras
- Physical camera ID 映射需要在初始化時完整建立
