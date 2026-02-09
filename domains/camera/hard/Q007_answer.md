# Q007 答案：Camera2 Session 切換時 Surface 狀態錯誤

## 問題根因

Session 切換時，舊 session 的 Surface 被過早 abandon，導致新 session 無法使用共享的 Surface。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraCaptureSessionImpl.java`

```java
@Override
public void close() {
    synchronized (mInterfaceLock) {
        // BUG: 立即 abandon 所有 surfaces，沒有等待新 session
        for (Surface surface : mConfiguredSurfaces) {
            mDeviceImpl.abandonSurface(surface);  // 過早
        }
        mClosed = true;
    }
}
```

**文件 2：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
private void configureSessionLocked(SessionConfiguration config) {
    // BUG: 順序錯誤 - 在配置新 session 前就關閉舊的
    if (mCurrentSession != null) {
        mCurrentSession.close();  // 這會 abandon surfaces
    }
    
    // 此時共享的 surfaces 已經 abandoned
    createSessionFromConfig(config);  // 失敗
}
```

**文件 3：** `frameworks/av/services/camera/libcameraservice/device3/Camera3Device.cpp`

```cpp
status_t Camera3Device::configureStreams(...) {
    // BUG: 不檢查 surface 狀態就嘗試配置
    for (auto& stream : streams) {
        // 缺少: if (stream.surface->isAbandoned()) continue;
        configureStream(stream);
    }
}
```

## 修復方法

```java
// CameraDeviceImpl.java
private void configureSessionLocked(SessionConfiguration config) {
    // 正確順序：先配置新 session，再清理舊 session
    CameraCaptureSession oldSession = mCurrentSession;
    
    // 創建新 session
    createSessionFromConfig(config);
    
    // 新 session 配置成功後再關閉舊的
    if (oldSession != null) {
        oldSession.close();
    }
}

// CameraCaptureSessionImpl.java
@Override
public void close() {
    synchronized (mInterfaceLock) {
        // 只 abandon 非共享的 surfaces
        for (Surface surface : mConfiguredSurfaces) {
            if (!isSharedSurface(surface)) {
                mDeviceImpl.abandonSurface(surface);
            }
        }
        mClosed = true;
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CameraDeviceTest#testSessionSwitching`
4. 測試應該通過

## 學習重點
- Session 切換需要正確管理 Surface 生命週期
- 共享 Surface 的 abandon 時機很重要
- 配置順序影響 Surface 狀態
