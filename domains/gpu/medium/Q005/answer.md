# Q005 Answer: EGL Sync Object Timeout Wrong

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglClientWaitSyncImpl()` 中，
timeout 參數被除以 1000000 轉換為毫秒，但驅動期望的是納秒。
這導致 100ms 變成 0.0001ms，幾乎立即超時。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - wait sync 實現
2. `frameworks/native/opengl/libs/EGL/eglApi.cpp` - API 入口

## 修復方式
```cpp
// 錯誤的代碼
EGLint eglClientWaitSyncImpl(..., EGLTimeKHR timeout) {
    // ...
    // BUG: 不需要轉換，驅動也期望 nanoseconds
    EGLTimeKHR driverTimeout = timeout / 1000000;
    return cnx->egl.eglClientWaitSyncKHR(dp->disp.dpy, sync, flags, driverTimeout);
}

// 正確的代碼
EGLint eglClientWaitSyncImpl(..., EGLTimeKHR timeout) {
    // ...
    return cnx->egl.eglClientWaitSyncKHR(dp->disp.dpy, sync, flags, timeout);
}
```

## 調試步驟
1. Log timeout 值在各層的變化
2. 確認 EGL spec 中 timeout 的單位
3. 驗證實際等待時間

## 相關知識
- EGLTimeKHR 是 nanoseconds
- 單位轉換錯誤是常見 bug
- fence sync 用於 GPU/CPU 同步

## 難度說明
**Medium** - 需要理解 sync API 並追蹤 timeout 參數的傳遞。
