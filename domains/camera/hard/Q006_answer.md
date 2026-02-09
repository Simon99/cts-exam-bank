# Q006 答案：High Speed Video Recording 幀率不穩定

## 問題根因

High speed session 的 burst size 計算錯誤，導致 repeating burst 請求間有空隙。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraConstrainedHighSpeedCaptureSessionImpl.java`

```java
private int calculateBurstSize(int targetFps) {
    // BUG: 計算公式錯誤
    int burstSize = targetFps / 60;  // 應該是 targetFps / 30
    return burstSize;  // 240fps 時返回 4，應該是 8
}

public void setRepeatingBurst(...) {
    int burstSize = calculateBurstSize(mTargetFps);
    // 因為 burst size 太小，幀間會有空隙
}
```

**文件 2：** `frameworks/av/services/camera/libcameraservice/device3/Camera3Device.cpp`

```cpp
status_t Camera3Device::submitHighSpeedRequestList(...) {
    // BUG: batch 間沒有正確銜接
    for (auto& request : requests) {
        // 每個 batch 之間有延遲
        usleep(1000);  // 不應該有這個延遲
        submitRequest(request);
    }
}
```

**文件 3：** `frameworks/av/services/camera/libcameraservice/api2/CameraDeviceClient.cpp`

```cpp
binder::Status CameraDeviceClient::submitRequestList(...) {
    // BUG: high speed 模式沒有正確設置 batch mode
    if (mIsHighSpeed) {
        // 缺少 batch processing flag
        mBatchMode = false;  // 應該是 true
    }
}
```

## 修復方法

```java
// CameraConstrainedHighSpeedCaptureSessionImpl.java
private int calculateBurstSize(int targetFps) {
    // 正確計算：High speed 需要 targetFps/30 的 burst size
    int burstSize = targetFps / 30;
    return burstSize;  // 240fps 返回 8
}
```

```cpp
// Camera3Device.cpp
status_t Camera3Device::submitHighSpeedRequestList(...) {
    // 移除不必要的延遲，連續提交
    for (auto& request : requests) {
        submitRequest(request);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework 和 camera service
3. 執行 `atest RecordingTest#testHighSpeedRecording`
4. 測試應該通過

## 學習重點
- High speed recording 需要精確的幀率控制
- Burst size 直接影響錄製穩定性
- Batch processing 對高速模式很重要
