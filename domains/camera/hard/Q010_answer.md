# Q010 答案：Camera Flash Torch Mode 狀態不同步

## 問題根因

Torch mode 狀態在更新和通知之間有競爭條件，導致 callback 收到舊的狀態。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/CameraManager.java`

```java
public void setTorchMode(@NonNull String cameraId, boolean enabled) {
    // BUG: 先通知再更新狀態
    CameraManagerGlobal.get().notifyTorchModeChanged(cameraId, mTorchEnabled);
    mTorchEnabled = enabled;  // 狀態更新在通知之後
    
    mCameraService.setTorchMode(cameraId, enabled);
}
```

**文件 2：** `frameworks/base/core/java/android/hardware/camera2/CameraManagerGlobal.java`

```java
private void onTorchStatusChangedLocked(int status, String cameraId) {
    // BUG: 狀態轉換邏輯錯誤
    boolean enabled = (status == ICameraServiceListener.TORCH_STATUS_AVAILABLE_ON);
    
    // 錯誤：AVAILABLE_OFF 被當作 disabled
    // 但 AVAILABLE_OFF 只是說 torch 可用但目前關閉
    // NOT_AVAILABLE 才是真的不可用
    if (status == ICameraServiceListener.TORCH_STATUS_AVAILABLE_OFF) {
        enabled = false;  // 這裡邏輯有問題
    }
    
    notifyTorchCallbacks(cameraId, enabled);
}
```

**文件 3：** `frameworks/av/services/camera/libcameraservice/CameraService.cpp`

```cpp
Status CameraService::setTorchMode(const String16& cameraId, bool enabled,
        const sp<IBinder>& clientBinder) {
    
    // BUG: 通知發送的時機錯誤
    // 在硬體操作完成前就發送通知
    notifyTorchModeStatus(cameraId, enabled ? 
        TorchModeStatus::AVAILABLE_ON : TorchModeStatus::AVAILABLE_OFF);
    
    // 實際硬體操作
    status_t res = mFlashlight->setTorchMode(cameraId, enabled);
    // 如果失敗，狀態已經錯誤通知出去了
}
```

## 修復方法

```java
// CameraManager.java
public void setTorchMode(@NonNull String cameraId, boolean enabled) {
    // 正確順序：先更新狀態，再通知
    mTorchEnabled = enabled;
    
    mCameraService.setTorchMode(cameraId, enabled);
    // 讓 service 的回調來通知，而不是這裡
}
```

```cpp
// CameraService.cpp
Status CameraService::setTorchMode(...) {
    // 先執行硬體操作
    status_t res = mFlashlight->setTorchMode(cameraId, enabled);
    
    if (res == OK) {
        // 成功後再通知
        notifyTorchModeStatus(cameraId, enabled ? ...);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework 和 camera service
3. 執行 `atest CameraManagerTest#testTorchCallback`
4. 測試應該通過

## 學習重點
- 狀態更新和通知的順序很重要
- 異步操作需要正確的完成通知時機
- 競爭條件在多層架構中很常見
