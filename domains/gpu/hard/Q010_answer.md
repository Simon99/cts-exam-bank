# Q010 Answer: EGL Display Reference Leak on Surface Destruction

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglDestroySurfaceImpl()` 函數中，
Surface 的 `terminate()` 方法被調用，但 `destroy()` 未被調用。

EGL object 的生命週期管理分兩個階段：
1. `terminate()`: 從 display 的 objects 集合中移除，減少一次 refcount
2. `destroy()`: 最終釋放資源，當 refcount 降為 0 時刪除對象

問題在於當 `eglDestroySurface()` 返回後，LocalRef 析構時應該調用 `destroy()`，
但由於提前 return，LocalRef 沒有正確析構。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - `eglDestroySurfaceImpl()`

## 關鍵代碼分析
```cpp
EGLBoolean eglDestroySurfaceImpl(EGLDisplay dpy, EGLSurface surface) {
    egl_display_t* dp = get_display(dpy);
    if (!dp) return setError(EGL_BAD_DISPLAY, (EGLBoolean)EGL_FALSE);
    
    // ContextRef 確保在這個 scope 內 surface 有效
    SurfaceRef _s(dp, surface);
    if (!_s.get()) return setError(EGL_BAD_SURFACE, (EGLBoolean)EGL_FALSE);
    
    egl_surface_t* s = _s.get();
    
    // 調用底層驅動
    EGLBoolean result = s->cnx->egl.eglDestroySurface(dp->disp.dpy, s->surface);
    if (result) {
        s->terminate();  // 從 display 移除
        // BUG: 這裡提前 return，SurfaceRef 析構時 surface 仍有 refs
        // 應該等 SurfaceRef 析構後才 return
    }
    return result;  // BUG: SurfaceRef 析構調用 destroy()，但 refs 計算錯誤
}
```

## 問題詳解
`SurfaceRef` (LocalRef) 的行為：
- 構造時：`incRef()` +1
- 析構時：`decRef()` 然後如果 refs==0 則 `delete`

但 `terminate()` 也會 `decRef()`，導致多減一次。

正確的流程應該是：
1. SurfaceRef 構造: refs = 1 -> 2
2. eglDestroySurface 驅動調用成功
3. terminate(): refs = 2 -> 1，從 objects 集合移除
4. SurfaceRef 析構: refs = 1 -> 0，觸發 delete

問題代碼中 terminate() 的 decRef() 和 SurfaceRef 的 decRef() 順序/邏輯有問題。

## 修復方式
```cpp
EGLBoolean eglDestroySurfaceImpl(EGLDisplay dpy, EGLSurface surface) {
    egl_display_t* dp = get_display(dpy);
    if (!dp) return setError(EGL_BAD_DISPLAY, (EGLBoolean)EGL_FALSE);
    
    SurfaceRef _s(dp, surface);
    if (!_s.get()) return setError(EGL_BAD_SURFACE, (EGLBoolean)EGL_FALSE);
    
    egl_surface_t* s = _s.get();
    EGLBoolean result = s->cnx->egl.eglDestroySurface(dp->disp.dpy, s->surface);
    
    if (result) {
        // 正確：在 SurfaceRef 析構前調用 terminate
        // SurfaceRef 析構會調用 destroy() 減少最後一個 ref
        s->terminate();
    }
    
    // SurfaceRef 會在這裡析構，正確處理 refs
    return result;
}
```

## 調試步驟
1. 在 `egl_object.cpp` 的 `incRef()`/`decRef()` 添加 log
2. 追蹤 surface 創建到銷毀的 refs 變化
3. 使用 `egl_get_init_count()` 檢查 display refs
4. 在 `~egl_surface_t()` 中添加 log 確認何時觸發

## 相關知識
- EGL 使用 LocalRef (RAII) 模式管理 object 生命週期
- `terminate()` 將 object 標記為"已銷毀"，但不一定釋放記憶體
- `destroy()` 真正減少 refcount，可能觸發 delete
- Reference counting 錯誤通常導致 memory leak 或 use-after-free

## 難度說明
**Hard** - 需要深入理解 C++ RAII 和引用計數機制。
問題涉及多個對象的交互，需要追蹤完整的對象生命週期。
