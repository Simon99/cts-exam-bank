# Q005 Answer: eglSwapBuffers Always Returns False

## 問題根因
在 `eglApi.cpp` 的 `eglSwapBuffers()` 函數中，
返回語句錯誤地返回了 platform 函數結果的反向值。

## Bug 位置
`frameworks/native/opengl/libs/EGL/eglApi.cpp`

## 修復方式
```cpp
// 錯誤的代碼
EGLBoolean eglSwapBuffers(EGLDisplay dpy, EGLSurface surface) {
    ATRACE_CALL();
    clearError();
    egl_connection_t* const cnx = &gEGLImpl;
    return !cnx->platform.eglSwapBuffers(dpy, surface);  // BUG: 多了 !
}

// 正確的代碼
EGLBoolean eglSwapBuffers(EGLDisplay dpy, EGLSurface surface) {
    ATRACE_CALL();
    clearError();
    egl_connection_t* const cnx = &gEGLImpl;
    return cnx->platform.eglSwapBuffers(dpy, surface);
}
```

## 相關知識
- EGL_TRUE = 1, EGL_FALSE = 0
- 驅動的返回值被意外取反
- 這類 bug 會導致所有渲染看起來都失敗，但實際上成功了

## 難度說明
**Easy** - fail log 顯示函數返回 false 但沒有錯誤，搜尋 eglSwapBuffers 即可找到返回值錯誤。
