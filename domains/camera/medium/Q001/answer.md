# Q001 答案：Capture 回調順序錯誤

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `CameraCaptureSessionImpl.java`：錯誤的 null check 條件會造成 NullPointerException
2. **根因檔案** `CameraDeviceImpl.java`：`onCaptureStarted` 回調被跳過

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraCaptureSessionImpl.java`

```java
// createCaptureCallbackProxyWithExecutor 內部類
@Override
public void onCaptureStarted(CameraDevice camera,
        CaptureRequest request, long timestamp, long frameNumber) {
    // BUG: 錯誤的條件（應為 AND，改成 OR）
    if ((callback != null) || (executor != null)) {  // 應該是 &&
        executor.execute(() -> callback.onCaptureStarted(...));
    }
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
// CameraDeviceCallbacks.onCaptureStarted
@Override
public void onCaptureStarted(final CaptureResultExtras resultExtras, final long timestamp) {
    // BUG: 直接返回，跳過所有回調處理
    if (true) {
        return;
    }
    // ... 正常處理邏輯
}
```

## 呼叫鏈

```
CameraService (native)
    ↓ ICameraDeviceCallbacks.onCaptureStarted()
CameraDeviceImpl.CameraDeviceCallbacks.onCaptureStarted()  ← BUG 在這裡
    ↓ holder.getCallback().onCaptureStarted()
CameraCaptureSessionImpl.CaptureCallback.onCaptureStarted() ← 線索在這裡
    ↓ callback.onCaptureStarted()
App's CaptureCallback.onCaptureStarted()
```

## 追蹤方法

1. 在 `CameraCaptureSessionImpl` 的 callback proxy 添加 log
2. 觀察到 `onCaptureStarted` 從未被呼叫
3. 追蹤上游：`CameraDeviceImpl.CameraDeviceCallbacks`
4. 發現 `onCaptureStarted` 方法中有異常的 `return`

## 修復方法

**文件 1：**
```java
// 修正條件為 AND
if ((callback != null) && (executor != null)) {
```

**文件 2：**
```java
// 移除錯誤的 return
@Override
public void onCaptureStarted(final CaptureResultExtras resultExtras, final long timestamp) {
    // 移除: if (true) { return; }
    
    int requestId = resultExtras.getRequestId();
    // ... 正常處理
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest CaptureResultTest#testCameraCaptureResultAllKeys`
4. 測試應該通過

## 學習重點
- Camera2 的回調是多層次的：Service → DeviceImpl → SessionImpl → App
- 追蹤 bug 需要理解完整呼叫鏈
- 線索可能在一個檔案，根因在另一個檔案
