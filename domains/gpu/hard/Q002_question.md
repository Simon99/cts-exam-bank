# Q002: Protected Content Rendering Fails

## CTS Test
`android.opengl.cts.EglProtectedContentTest#testProtectedTextureRendering`

## Failure Log
```
junit.framework.AssertionFailedError: Protected content rendering failed

EGL_EXT_protected_content extension present: YES
Protected context created: YES
Protected surface created: YES
Protected texture created: YES

Rendering to protected surface: FAILED
Error: GL_INVALID_OPERATION during glTexImage2D with protected buffer

Protected content path appears broken despite all components reporting success

at android.opengl.cts.EglProtectedContentTest.testProtectedTextureRendering(EglProtectedContentTest.java:189)
```

## 現象描述
設備宣告支援 protected content (DRM)，所有元件創建都成功，
但實際渲染 protected 內容時失敗。

## 提示
- Protected content 需要整個 pipeline 支援：context, surface, texture, buffer
- 問題可能出在某個元件沒有正確傳播 protected flag
- 需要追蹤 protected attribute 從 EGL 到 GL 到 buffer 的完整路徑
