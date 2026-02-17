# Q003 Answer: EGL Bad Display Error on Initialization

## 問題根因
在 `egl_display.cpp` 的 `get()` 函數中，display pointer 的驗證邏輯錯誤。
將 `uintptr_t(dpy) == 0` 的檢查條件錯誤地寫成 `uintptr_t(dpy) != 0`，
導致所有有效的 display 都被判定為無效。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_display.cpp`

## 修復方式
```cpp
// 錯誤的代碼
egl_display_t* egl_display_t::get(EGLDisplay dpy) {
    if (uintptr_t(dpy) != 0) {  // BUG: 應該是 == 0
        return nullptr;
    }
    // ...
}

// 正確的代碼
egl_display_t* egl_display_t::get(EGLDisplay dpy) {
    if (uintptr_t(dpy) == 0) {
        return nullptr;
    }
    // ...
}
```

## 相關知識
- EGLDisplay 是一個 opaque pointer，0/nullptr 表示無效
- `egl_display_t::get()` 是驗證 display 有效性的核心函數
- 所有 EGL 操作都會先驗證 display

## 難度說明
**Easy** - 錯誤訊息明確指出 BAD_DISPLAY，只需檢查 display 驗證函數即可找到邏輯錯誤。
