# Q009: EGL Surface Creation Fails

## CTS Test
`android.opengl.cts.EglSurfacesTest#testCreateWindowSurface`

## Failure Log
```
junit.framework.AssertionFailedError: eglCreateWindowSurface returned EGL_NO_SURFACE
EGL error: EGL_BAD_NATIVE_WINDOW (0x300B)

at android.opengl.cts.EglSurfacesTest.testCreateWindowSurface(EglSurfacesTest.java:124)
```

## 現象描述
`eglCreateWindowSurface()` 返回 `EGL_NO_SURFACE`，
錯誤碼為 `EGL_BAD_NATIVE_WINDOW`，表示 native window 驗證失敗。
但傳入的 window 實際上是有效的。

## 提示
- EGL_BAD_NATIVE_WINDOW 表示 window 參數無效
- 檢查 window 參數的驗證邏輯
- 問題可能出在 NULL 檢查的條件
