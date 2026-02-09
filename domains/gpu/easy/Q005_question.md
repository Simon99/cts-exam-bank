# Q005: eglSwapBuffers Always Returns False

## CTS Test
`android.opengl.cts.GLSurfaceViewTest#testEGLSwapBuffers`

## Failure Log
```
junit.framework.AssertionFailedError: eglSwapBuffers() failed
EGL error: EGL_SUCCESS (0x3000)

at android.opengl.cts.GLSurfaceViewTest.testEGLSwapBuffers(GLSurfaceViewTest.java:156)
```

## 現象描述
`eglSwapBuffers()` 返回 `EGL_FALSE`，但 `eglGetError()` 卻顯示 `EGL_SUCCESS`。
這表示 swap buffers 操作失敗但沒有設置錯誤碼。

## 提示
- eglSwapBuffers 應在成功時返回 EGL_TRUE
- 問題可能出在返回值的處理
- 注意 EGL_TRUE 和 EGL_FALSE 的定義
