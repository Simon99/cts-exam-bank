# Q004 Answer: glGetError Returns Wrong Error Code

## 問題根因
在 `eglApi.cpp` 的 `eglGetError()` 函數中，錯誤地在返回錯誤碼之前調用了 `clearError()`，
導致錯誤被清除後才查詢，永遠返回 GL_NO_ERROR。

## Bug 位置
`frameworks/native/opengl/libs/EGL/eglApi.cpp`

## 修復方式
```cpp
// 錯誤的代碼
EGLint eglGetError(void) {
    clearError();  // BUG: 不應該在查詢前清除
    egl_connection_t* const cnx = &gEGLImpl;
    return cnx->platform.eglGetError();
}

// 正確的代碼
EGLint eglGetError(void) {
    egl_connection_t* const cnx = &gEGLImpl;
    return cnx->platform.eglGetError();
}
```

## 相關知識
- OpenGL/EGL 錯誤狀態是全域的，查詢後自動清除
- `clearError()` 應該在操作開始前調用，不是在查詢時
- CTS 測試會驗證錯誤回報機制是否正確

## 難度說明
**Easy** - fail log 顯示預期值與實際值的差異，搜尋 `eglGetError` 函數即可發現問題。
