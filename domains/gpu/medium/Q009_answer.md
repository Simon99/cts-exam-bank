# Q009 Answer: Presentation Time Not Applied

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglPresentationTimeANDROIDImpl()` 中，
時間戳被存儲但沒有在 `eglSwapBuffers` 時傳遞給 native window。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - presentation time 設置
2. `frameworks/native/opengl/libs/EGL/egl_object.cpp` - surface object 存儲時間戳

## 修復方式
```cpp
// 錯誤的代碼 (在 swapBuffers 中)
EGLBoolean eglSwapBuffersImpl(...) {
    // ...
    // BUG: presentationTime 沒有被使用
    // native_window_set_buffers_timestamp(win, surface->presentationTime);
    result = cnx->egl.eglSwapBuffers(dp->disp.dpy, s->surface);
    return result;
}

// 正確的代碼
EGLBoolean eglSwapBuffersImpl(...) {
    // ...
    if (surface->presentationTime != 0) {
        native_window_set_buffers_timestamp(win, surface->presentationTime);
        surface->presentationTime = 0;  // reset after use
    }
    result = cnx->egl.eglSwapBuffers(dp->disp.dpy, s->surface);
    return result;
}
```

## 調試步驟
1. Log presentationTime 在設置和 swap 時的值
2. 追蹤 native_window_set_buffers_timestamp 的調用
3. 檢查 surface object 中時間戳的存儲和使用

## 相關知識
- Presentation time 用於幀同步
- 時間戳傳遞給 SurfaceFlinger 控制呈現時機
- 常用於遊戲和視頻應用的幀節奏控制

## 難度說明
**Medium** - 需要理解 presentation time 的傳遞路徑，追蹤跨函數的資料流。
