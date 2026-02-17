# Q004 Answer: Frame Timestamps Inconsistent

## 問題根因
Frame timestamps 流程涉及：
1. `egl_platform_entries.cpp` - API 實現
2. `egl_object.cpp` - surface 存儲時間戳
3. `ANativeWindow` - 與 SurfaceFlinger 通訊
4. SurfaceFlinger - 提供實際時間戳

問題出在 `egl_platform_entries.cpp` 的 `eglGetCompositorTimingANDROIDImpl()` 中，
每次查詢都使用緩存的時間戳，沒有調用 `native_window_get_compositor_timing()` 更新。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - timing API
2. `frameworks/native/opengl/libs/EGL/egl_object.cpp` - 時間戳緩存
3. `frameworks/native/libs/gui/Surface.cpp` - native window 實現

## 修復方式
```cpp
// 錯誤的代碼 (egl_platform_entries.cpp)
EGLBoolean eglGetCompositorTimingANDROIDImpl(...) {
    // ...
    // 使用緩存的值
    for (int i = 0; i < numTimestamps; i++) {
        values[i] = s->cachedTimestamps[names[i]];  // BUG: always cached
    }
    return EGL_TRUE;
}

// 正確的代碼
EGLBoolean eglGetCompositorTimingANDROIDImpl(...) {
    // ...
    // Query fresh timestamps from native window
    ANativeWindow* win = s->getNativeWindow();
    nsecs_t compositeDeadline, compositeInterval, compositeToPresentLatency;
    int err = native_window_get_compositor_timing(win, &compositeDeadline,
                                                   &compositeInterval,
                                                   &compositeToPresentLatency);
    if (err != OK) {
        return setError(EGL_BAD_SURFACE, EGL_FALSE);
    }
    // Update cache and return values
    // ...
}
```

## 調試步驟
1. 在 eglGetCompositorTimingANDROID 添加 log
2. 追蹤 native_window_get_compositor_timing 的調用
3. 比較 SurfaceFlinger 返回的值和 EGL 返回的值
4. 檢查緩存更新時機

## 難度說明
**Hard** - 跨越 EGL、Surface、SurfaceFlinger 多個元件，需要理解時間戳同步機制。
