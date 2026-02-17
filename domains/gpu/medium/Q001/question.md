# Q001: EGL Context Creation Fails Intermittently

## CTS Test
`android.opengl.cts.EglContextTest#testCreateContext`

## Failure Log
```
junit.framework.AssertionFailedError: eglCreateContext returned EGL_NO_CONTEXT
EGL error: EGL_BAD_MATCH (0x3009)

Test passed on retry, appears to be race condition

at android.opengl.cts.EglContextTest.testCreateContext(EglContextTest.java:142)
```

## 現象描述
`eglCreateContext()` 間歇性失敗，返回 `EGL_BAD_MATCH` 錯誤。
重試時經常成功。這表明存在競態條件。

## 提示
- EGL_BAD_MATCH 通常表示參數不匹配
- 但間歇性失敗暗示是時序問題
- 可能需要檢查初始化狀態的同步
- 考慮檢查 eglIsInitialized 的狀態
