# Q005 答案：Repeating Request 無法正常停止

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `CameraCaptureSessionImpl.java`：`stopRepeating()` 有 log 但委派給 DeviceImpl
2. **根因檔案** `CameraDeviceImpl.java`：`cancelRequest()` 被註釋掉了

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraCaptureSessionImpl.java`

```java
@Override
public void stopRepeating() throws CameraAccessException {
    synchronized (mDeviceImpl.mInterfaceLock) {
        // 線索 log：stopRepeating 被呼叫了
        Log.v(TAG, mIdString + "stopRepeating called, mAborting=" + mAborting);
        
        checkNotClosed();
        mDeviceImpl.stopRepeating();  // 委派給 CameraDeviceImpl
    }
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
public long stopRepeating() throws CameraAccessException {
    synchronized(mInterfaceLock) {
        checkIfCameraClosedOrInError();

        if (mRepeatingRequestId != REQUEST_ID_NONE) {
            int requestId = mRepeatingRequestId;
            mRepeatingRequestId = REQUEST_ID_NONE;

            // BUG: 這行被註釋掉了！
            // mRemoteDevice.cancelRequest(requestId);

            checkEarlyTriggerSequenceCompleteLocked(...);
            // ...
        }
    }
}
```

## 呼叫鏈

```
App 呼叫 CameraCaptureSession.stopRepeating()
    ↓
CameraCaptureSessionImpl.stopRepeating()  ← 線索 log
    ↓ mDeviceImpl.stopRepeating()
CameraDeviceImpl.stopRepeating()  ← BUG：cancelRequest 被註釋
    ↓ (應該呼叫) mRemoteDevice.cancelRequest()
CameraService (native)
```

## 追蹤方法

1. 觀察 CTS 測試：`stopRepeating()` 後 `onCaptureSequenceCompleted` 沒有被呼叫
2. 在 `CameraCaptureSessionImpl.stopRepeating()` 看到 log
3. 追蹤到 `CameraDeviceImpl.stopRepeating()`
4. 發現 `cancelRequest()` 被註釋掉

## 修復方法

**文件 2（必須修復）：**
```java
public long stopRepeating() throws CameraAccessException {
    synchronized(mInterfaceLock) {
        // ...
        if (mRepeatingRequestId != REQUEST_ID_NONE) {
            int requestId = mRepeatingRequestId;
            mRepeatingRequestId = REQUEST_ID_NONE;

            // 恢復這行
            mRemoteDevice.cancelRequest(requestId);

            // ...
        }
    }
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest CameraDeviceTest#testCameraDeviceRepeatingRequest`
4. 測試應該通過

## 學習重點
- Repeating Request 的停止需要通知 CameraService
- `cancelRequest()` 是觸發 `onCaptureSequenceCompleted` 的關鍵
- Session 和 Device 層的職責分工
