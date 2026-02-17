# Q010 Answer: EGL Terminate Leaks Reference Count

## 問題根因
在 `egl_display.cpp` 的 `terminate()` 函數中，
當 refs 大於 1 時直接返回 EGL_TRUE，但忘記在返回前先做 `refs--`。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_display.cpp`

## 修復方式
```cpp
// 錯誤的代碼
EGLBoolean egl_display_t::terminate() {
    std::unique_lock<std::mutex> _rl(refLock);
    if (refs == 0) {
        return EGL_TRUE;
    }
    
    // refs--;  // BUG: 這行被註解掉或刪除了
    if (refs > 0) {
        return EGL_TRUE;
    }
    // ...
}

// 正確的代碼
refs--;
if (refs > 0) {
    return EGL_TRUE;
}
```

## 相關知識
- Android EGL 的 display 是引用計數的（與 EGL 規範略有不同）
- 多個 eglInitialize 調用需要對應數量的 eglTerminate
- 引用計數錯誤會導致資源洩漏或過早釋放

## 難度說明
**Easy** - fail log 指出 refs count 不正確，檢查 terminate 的 refs 操作即可發現遺漏的減法。
