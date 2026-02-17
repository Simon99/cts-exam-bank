# Q008 Answer: EGL Image Creation Memory Leak

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglDestroyImageImpl()` 中，
調用驅動的 destroy 函數後，沒有 release 與 image 關聯的 native buffer 引用。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - image destroy
2. `frameworks/native/opengl/libs/EGL/egl_object.cpp` - image object 定義

## 修復方式
```cpp
// 錯誤的代碼
EGLBoolean eglDestroyImageImpl(EGLDisplay dpy, EGLImage image) {
    // ...
    EGLBoolean result = cnx->egl.eglDestroyImageKHR(dp->disp.dpy, image);
    // BUG: 缺少 buffer release
    // nativeBuffer->release();  // 這行被遺漏了
    return result;
}

// 正確的代碼
EGLBoolean eglDestroyImageImpl(EGLDisplay dpy, EGLImage image) {
    // ...
    if (img->buffer) {
        img->buffer->common.decRef(&img->buffer->common);
    }
    EGLBoolean result = cnx->egl.eglDestroyImageKHR(dp->disp.dpy, image);
    return result;
}
```

## 調試步驟
1. 使用 dumpsys meminfo 追蹤記憶體
2. 在 create/destroy 添加 log 記錄 buffer 地址
3. 檢查 buffer reference count 的變化

## 相關知識
- EGLImage 可以 wrap native buffer
- Native buffer 使用引用計數管理生命週期
- 忘記 decRef 會導致記憶體洩漏

## 難度說明
**Medium** - 需要理解 EGLImage 和 buffer 的關係，追蹤引用計數。
