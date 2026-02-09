# Q009 答案：CaptureRequest 批量提交 Ordering 錯亂

## 問題根因

Burst capture 的結果回調使用了並行線程池，導致順序無法保證。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
private class CameraDeviceCallbacks extends ICameraDeviceCallbacks.Stub {
    @Override
    public void onResultReceived(CaptureResultExtras resultExtras, 
            CameraMetadataNative result) {
        // BUG: 使用並行 executor 分發結果
        mCallbackExecutor.execute(() -> {
            // 並行執行導致順序錯亂
            mCallback.onCaptureCompleted(session, request, totalResult);
        });
    }
}
```

**文件 2：** `frameworks/av/services/camera/libcameraservice/device3/Camera3Device.cpp`

```cpp
void Camera3Device::processCompletedRequest(CaptureResult& result) {
    // BUG: 結果處理沒有按 frame number 排序
    Mutex::Autolock l(mOutputLock);
    
    // 直接加入列表，沒有按序插入
    mResultQueue.push_back(result);
    
    // 喚醒等待線程
    mResultSignal.signal();
}

void Camera3Device::sendCaptureResult(...) {
    // BUG: 從 queue 取出時不保證順序
    while (!mResultQueue.empty()) {
        auto result = mResultQueue.front();
        mResultQueue.pop_front();
        // 可能亂序發送
    }
}
```

**文件 3：** `frameworks/base/core/java/android/hardware/camera2/impl/CallbackProxies.java`

```java
public class SessionCallbackProxy ... {
    // BUG: 沒有維護順序的機制
    private void notifyCallback(CaptureCallback callback, ...) {
        // 直接調用，不等待前面的完成
    }
}
```

## 修復方法

```java
// CameraDeviceImpl.java
private class CameraDeviceCallbacks extends ICameraDeviceCallbacks.Stub {
    private final Object mResultOrderLock = new Object();
    private long mNextExpectedFrameNumber = 0;
    
    @Override
    public void onResultReceived(...) {
        synchronized (mResultOrderLock) {
            // 等待正確的順序
            while (resultExtras.frameNumber != mNextExpectedFrameNumber) {
                mResultOrderLock.wait();
            }
            mCallback.onCaptureCompleted(...);
            mNextExpectedFrameNumber++;
            mResultOrderLock.notifyAll();
        }
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest BurstCaptureTest#testBurstCaptureOrdering`
4. 測試應該通過

## 學習重點
- Burst capture 需要嚴格的結果順序
- 並行 callback 需要同步機制
- Frame number 可以用於排序依據
