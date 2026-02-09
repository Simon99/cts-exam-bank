# Q002 答案：Offline Session 切換失敗

## 問題根因

在 offline session 切換流程中，pending request 的狀態沒有被正確轉移。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
public CameraOfflineSession switchToOffline(...) {
    // BUG: 沒有正確傳遞 pending requests
    List<CaptureRequest> pendingRequests = new ArrayList<>();
    // pendingRequests 是空的！應該從 mCaptureCallbackMap 獲取
    
    return new CameraOfflineSessionImpl(pendingRequests, ...);
}
```

**文件 2：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraOfflineSessionImpl.java`

```java
public void initialize() {
    // BUG: 當 pending requests 為空時觸發 switch failed
    if (mPendingRequests.isEmpty()) {
        notifySwitchFailed();  // 錯誤地觸發失敗
    }
}
```

**文件 3：** `frameworks/base/core/java/android/hardware/camera2/impl/RequestLastFrameNumbersHolder.java`

```java
// Pending request 計數沒有被正確更新
```

## 修復方法

```java
// CameraDeviceImpl.java
public CameraOfflineSession switchToOffline(...) {
    // 正確獲取 pending requests
    List<CaptureRequest> pendingRequests = new ArrayList<>();
    for (int i = 0; i < mCaptureCallbackMap.size(); i++) {
        pendingRequests.addAll(mCaptureCallbackMap.valueAt(i).getRequests());
    }
    
    return new CameraOfflineSessionImpl(pendingRequests, ...);
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest OfflineSessionTest#testOfflineSessionSwitch`
4. 測試應該通過

## 學習重點
- Offline session 允許在關閉相機後繼續處理 capture
- 狀態轉移是關鍵：所有 pending request 必須轉移到 offline session
- 多個類之間的狀態同步容易出錯
