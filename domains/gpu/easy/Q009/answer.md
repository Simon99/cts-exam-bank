# Q009 Answer: EGL Surface Creation Fails

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglCreateWindowSurfaceImpl()` 函數中，
window 參數的 NULL 檢查邏輯被反轉了。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp`

## 修復方式
```cpp
// 錯誤的代碼
EGLSurface eglCreateWindowSurfaceImpl(..., NativeWindowType window, ...) {
    // ...
    if (window != nullptr) {  // BUG: 應該是 window == nullptr
        return setError(EGL_BAD_NATIVE_WINDOW, EGL_NO_SURFACE);
    }
    // ...
}

// 正確的代碼
if (window == nullptr) {
    return setError(EGL_BAD_NATIVE_WINDOW, EGL_NO_SURFACE);
}
```

## 相關知識
- NativeWindowType 是 ANativeWindow* 的 typedef
- nullptr 表示無效的 window
- 這種邏輯反轉錯誤會導致有效 window 被拒絕

## 難度說明
**Easy** - 錯誤訊息明確指出 BAD_NATIVE_WINDOW，搜尋 createWindowSurface 的 window 驗證即可找到。
