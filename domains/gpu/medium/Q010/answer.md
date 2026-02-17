# Q010 Answer: GL Hooks Not Set for New Thread

## 問題根因
在 `egl_display.cpp` 的 `makeCurrent()` 中，
當 context 成功 make current 後，沒有調用 `setGLHooksThreadSpecific()` 
為當前線程設置 GL hooks。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - makeCurrent 實現
2. `frameworks/native/opengl/libs/EGL/egl_tls.cpp` - thread-local storage

## 修復方式
```cpp
// 錯誤的代碼
EGLBoolean egl_display_t::makeCurrent(...) {
    // ...
    result = c->cnx->egl.eglMakeCurrent(disp.dpy, impl_draw, impl_read, impl_ctx);
    if (result == EGL_TRUE) {
        c->onMakeCurrent(draw, read);
        // BUG: 缺少 setGLHooksThreadSpecific
    }
    return result;
}

// 正確的代碼
EGLBoolean egl_display_t::makeCurrent(...) {
    // ...
    result = c->cnx->egl.eglMakeCurrent(disp.dpy, impl_draw, impl_read, impl_ctx);
    if (result == EGL_TRUE) {
        c->onMakeCurrent(draw, read);
        setGLHooksThreadSpecific(c->cnx->hooks[c->version]);
    }
    return result;
}
```

## 調試步驟
1. 在 makeCurrent 添加 log 記錄 thread ID
2. 追蹤 setGLHooksThreadSpecific 的調用
3. 檢查 TLS 中的 hooks pointer

## 相關知識
- GL hooks 使用 TLS 實現 per-thread 綁定
- 每個線程需要獨立的 hooks 設置
- 沒有 hooks 會導致 GL 調用無法 dispatch

## 難度說明
**Medium** - 需要理解 TLS 和 GL hooks 機制，追蹤多線程場景。
