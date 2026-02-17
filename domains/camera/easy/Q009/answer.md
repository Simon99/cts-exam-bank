# Q009 答案：CameraDevice close() 不觸發 onClosed 回調

## 問題根因

在 `CameraDeviceImpl.java` 的 `close()` 方法中，onClosed 回調的分發被跳過了。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
@Override
public void close() {
    synchronized (mInterfaceLock) {
        if (mClosing.getAndSet(true)) {
            return;
        }
        
        // ... 清理資源 ...
        
        // BUG: 註釋掉了 onClosed 回調
        // mDeviceExecutor.execute(mCallOnClosed);  // 被註釋掉了！
    }
}
```

## 修復方法

```java
@Override
public void close() {
    synchronized (mInterfaceLock) {
        if (mClosing.getAndSet(true)) {
            return;
        }
        
        // ... 清理資源 ...
        
        // 確保觸發 onClosed 回調
        mDeviceExecutor.execute(mCallOnClosed);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CameraDeviceTest#testCameraDeviceClose`
4. 測試應該通過

## 學習重點
- CameraDevice.StateCallback 是管理相機生命週期的關鍵介面
- onClosed() 回調對於資源管理很重要
- 被註釋掉的代碼是常見的 bug 來源
