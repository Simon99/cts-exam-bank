# Q005 Answer: GPU Memory Corruption on Context Switch

## 問題根因
Context switch 需要：
1. `egl_display.cpp` - orchestrate context switch
2. `egl_platform_entries.cpp` - 調用驅動 makeCurrent
3. `egl_object.cpp` - context/surface 狀態管理
4. Driver - 實際 GPU state switch

問題出在 `egl_display.cpp` 的 `makeCurrent()` 中，
切換 context 前沒有對舊 context 調用 `glFlush()`，
導致前一個 context 的 GPU 命令可能還在執行中就被切換了。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - context switch 邏輯
2. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - makeCurrent 實現
3. `frameworks/native/opengl/libs/EGL/egl_object.cpp` - context state

## 修復方式
```cpp
// 錯誤的代碼 (egl_display.cpp)
EGLBoolean egl_display_t::makeCurrent(egl_context_t* c, egl_context_t* cur_c, ...) {
    // BUG: Missing flush before switch
    // if (cur_c && cur_c != c) {
    //     cur_c->cnx->hooks[cur_c->version]->gl.glFlush();
    // }
    
    result = c->cnx->egl.eglMakeCurrent(disp.dpy, impl_draw, impl_read, impl_ctx);
    // ...
}

// 正確的代碼
EGLBoolean egl_display_t::makeCurrent(egl_context_t* c, egl_context_t* cur_c, ...) {
    // Flush pending commands on current context before switching
    if (cur_c && cur_c != c) {
        cur_c->cnx->hooks[cur_c->version]->gl.glFlush();
    }
    
    result = c->cnx->egl.eglMakeCurrent(disp.dpy, impl_draw, impl_read, impl_ctx);
    // ...
}
```

## 調試步驟
1. 在 makeCurrent 前後添加 log 記錄 context 地址
2. 添加 glFinish() 確認是否是同步問題
3. 使用 GPU debugger 追蹤命令順序
4. 檢查 fence sync 的使用

## 相關知識
- GPU 命令是異步執行的
- Context switch 需要確保前一個 context 的命令完成
- glFlush 提交命令，glFinish 等待完成

## 難度說明
**Hard** - 涉及 GPU 異步執行模型，需要理解多 context 的 state machine。
