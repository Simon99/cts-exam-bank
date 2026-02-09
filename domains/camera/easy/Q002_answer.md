# Q002 答案：Flashlight Torch 回調未觸發

## 問題根因

在 `CameraManager.java` 的 `TorchCallback` 分發邏輯中，有一個條件導致回調被跳過。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/CameraManager.java`

在處理 torch 狀態變化時，回調分發被意外禁用：

```java
private void postSingleTorchUpdate(final TorchCallback callback, final Executor executor,
        final String id, final boolean enabled) {
    // BUG: 添加了一個始終為 true 的跳過條件
    if (true) {  // 這導致回調永遠不會被執行
        return;
    }
    
    final long ident = Binder.clearCallingIdentity();
    try {
        executor.execute(() -> callback.onTorchModeChanged(id, enabled));
    } finally {
        Binder.restoreCallingIdentity(ident);
    }
}
```

## 修復方法

```java
private void postSingleTorchUpdate(final TorchCallback callback, final Executor executor,
        final String id, final boolean enabled) {
    // 移除錯誤的 return 語句
    final long ident = Binder.clearCallingIdentity();
    try {
        executor.execute(() -> callback.onTorchModeChanged(id, enabled));
    } finally {
        Binder.restoreCallingIdentity(ident);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest FlashlightTest#testSetTorchModeOnOff`
4. 測試應該通過

## 學習重點
- Android Camera API 使用回調模式通知狀態變化
- 回調分發邏輯中的任何中斷都會導致功能失效
- Mockito 的 verify 可以幫助驗證回調是否被正確調用
