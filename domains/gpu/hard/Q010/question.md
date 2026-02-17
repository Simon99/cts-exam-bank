# Q010: EGL Display Reference Leak on Surface Destruction

## CTS Test
`android.opengl.cts.EglDisplayLeakTest#testSurfaceDestroyRefCount`

## Failure Log
```
FAILED: android.opengl.cts.EglDisplayLeakTest#testSurfaceDestroyRefCount

java.lang.AssertionError: EGL Display reference count leak detected

Test sequence:
  1. eglGetDisplay() - refs: 0 -> 1
  2. eglInitialize() - refs: 1 (OK)
  3. eglCreateWindowSurface() - refs: 1 -> 2
  4. eglMakeCurrent(surface) - refs: 2 (OK)
  5. eglMakeCurrent(EGL_NO_SURFACE) - refs: 2 (OK)
  6. eglDestroySurface() - refs: 2 (should be 1!)
  7. eglTerminate() - failed, refs still > 0

E/libEGL: eglTerminate: display 0x7f8a234560 still has 1 reference(s)
E/libEGL: Leaked objects:
E/libEGL:   egl_surface_t: 0 (destroyed but refs not decremented)
W/libEGL: Forcing terminate with leaked references

Memory leak: EGLSurface destructor never called
Native window reference leaked: ANativeWindow@0x7f8a567890
```

## 現象描述
在反覆創建和銷毀 EGL surface 後，系統出現 EGL display reference 洩漏。
`eglDestroySurface()` 未正確減少 display 的引用計數，
導致 `eglTerminate()` 無法正確清理資源。

## 提示
- EGL objects (surface, context) 使用引用計數管理生命週期
- `egl_display_t` 追蹤所有關聯的 objects
- Surface 銷毀涉及 `terminate()` 和 `destroy()` 兩個階段
- 需要理解 `egl_object.cpp` 中的引用計數機制
- 問題可能在 `eglDestroySurface()` 的 LocalRef 處理
