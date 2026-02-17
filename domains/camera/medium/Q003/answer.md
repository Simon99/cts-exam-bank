# Q003 答案：Camera Availability 回調不一致

## 問題根因

這是一個同檔案內兩個位置的 bug：
1. **位置 1** `isAvailable()` 方法：對未知狀態錯誤返回 true
2. **位置 2** `postSingleUpdate()` 方法：反轉了 isAvailable 的判斷

## Bug 位置

**文件：** `frameworks/base/core/java/android/hardware/camera2/CameraManager.java`

**Bug 1 - isAvailable() 方法（約 2474 行）：**
```java
private boolean isAvailable(int status) {
    switch (status) {
        case ICameraServiceListener.STATUS_PRESENT:
            return true;
        case ICameraServiceListener.STATUS_NOT_AVAILABLE:
            return false;
        default:
            return true;  // BUG: 未知狀態也返回 true
    }
}
```

**Bug 2 - postSingleUpdate() 方法（約 2554 行）：**
```java
private void postSingleUpdate(final AvailabilityCallback callback, final Executor executor,
        final String id, final String physicalId, final int status) {
    // BUG: 反轉了 isAvailable 的結果
    if (!isAvailable(status)) {  // 應該是 if (isAvailable(status))
        // ... 執行 onCameraAvailable
    } else {
        // ... 執行 onCameraUnavailable
    }
}
```

## 呼叫鏈

```
CameraService (native)
    ↓ ICameraServiceListener.onStatusChanged()
CameraManagerGlobal.CameraServiceListener.onStatusChanged()
    ↓ updateStatus()
    ↓ postSingleUpdate()  ← Bug 2：反轉判斷
        ↓ isAvailable()   ← Bug 1：錯誤返回值
    ↓ executor.execute()
App's AvailabilityCallback.onCameraAvailable/Unavailable()
```

## 追蹤方法

1. 在 `AvailabilityCallback` 添加 log 追蹤收到的狀態
2. 同時 log `isAvailable()` 的輸入和輸出
3. 觀察 `postSingleUpdate()` 的行為
4. 發現兩處邏輯錯誤導致最終結果反轉

## 修復方法

**Bug 1：**
```java
private boolean isAvailable(int status) {
    switch (status) {
        case ICameraServiceListener.STATUS_PRESENT:
            return true;
        default:
            return false;  // 正確：非 PRESENT 都是不可用
    }
}
```

**Bug 2：**
```java
private void postSingleUpdate(...) {
    if (isAvailable(status)) {  // 移除 !
        // onCameraAvailable
    } else {
        // onCameraUnavailable
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CameraManagerTest#testCameraManagerAvailabilityCallback`
4. 測試應該通過

## 學習重點
- 一個檔案內可能有多個相關 bug
- 邏輯反轉可能被另一個反轉"抵消"，產生部分正確行為
- 需要完整追蹤狀態流轉才能找到所有問題
