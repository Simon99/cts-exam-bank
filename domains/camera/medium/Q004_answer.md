# Q004 答案：Session Configuration 支援檢查錯誤

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `CameraDeviceSetupImpl.java`：加了 debug log 但委派給 CameraDeviceImpl
2. **根因檔案** `CameraDeviceImpl.java`：錯誤地對 JPEG 格式返回 false

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceSetupImpl.java`

```java
@Override
public boolean isSessionConfigurationSupported(
        @NonNull SessionConfiguration sessionConfig) throws CameraAccessException {
    // 線索：這裡有 log 但實際邏輯在 CameraDeviceImpl
    for (OutputConfiguration output : sessionConfig.getOutputConfigurations()) {
        Log.d(TAG, "Checking output format: " + ...);
    }
    
    // 委派給 CameraDeviceImpl
    return mCameraDeviceImpl.isSessionConfigurationSupported(sessionConfig);
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
public boolean isSessionConfigurationSupported(
        @NonNull SessionConfiguration sessionConfig) throws CameraAccessException {
    synchronized(mInterfaceLock) {
        checkIfCameraClosedOrInError();
        
        // BUG: 對 JPEG 格式錯誤地返回 false
        for (OutputConfiguration output : sessionConfig.getOutputConfigurations()) {
            Surface surface = output.getSurface();
            if (surface != null) {
                int format = SurfaceUtils.getSurfaceFormat(surface);
                if (format == ImageFormat.JPEG) {
                    return false;  // 錯誤！JPEG 是合法格式
                }
            }
        }
        // ... 正常檢查
    }
}
```

## 呼叫鏈

```
App 呼叫 CameraDevice.isSessionConfigurationSupported()
    ↓
CameraDeviceSetupImpl.isSessionConfigurationSupported()  ← 線索 log
    ↓ mCameraDeviceImpl.isSessionConfigurationSupported()
CameraDeviceImpl.isSessionConfigurationSupported()  ← BUG 在這裡
    ↓
回傳 false（對 JPEG 格式）
```

## 追蹤方法

1. 觀察 CTS 測試失敗：`isSessionConfigurationSupported` 對 JPEG 返回 false
2. 在 `CameraDeviceSetupImpl` 看到 log 顯示有 surface
3. 追蹤到 `CameraDeviceImpl` 發現錯誤的 JPEG 檢查

## 修復方法

**文件 1（可選清理）：** 移除不必要的 log

**文件 2（必須修復）：**
```java
public boolean isSessionConfigurationSupported(...) {
    synchronized(mInterfaceLock) {
        checkIfCameraClosedOrInError();
        
        // 移除錯誤的 JPEG 檢查
        // JPEG 是合法的 output 格式
        
        return mCameraDeviceSetup != null ?
                mCameraDeviceSetup.isSessionConfigurationSupported(sessionConfig) :
                mRemoteDevice.isSessionConfigurationSupported(sessionConfig);
    }
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest CameraDeviceTest#testSessionConfiguration`
4. 測試應該通過

## 學習重點
- 委派模式（Delegation Pattern）中，bug 可能在被委派的類別
- log 線索可能指向一個檔案，但問題在另一個
- 理解 CameraDeviceSetup 和 CameraDeviceImpl 的關係
