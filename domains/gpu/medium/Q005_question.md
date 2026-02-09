# Q005: EGL Sync Object Timeout Wrong

## CTS Test
`android.opengl.cts.EglSurfacesTest#testFenceSync`

## Failure Log
```
junit.framework.AssertionFailedError: eglClientWaitSync timeout behavior incorrect

Expected: return EGL_TIMEOUT_EXPIRED after ~100ms
Actual: returned EGL_CONDITION_SATISFIED immediately

Wait time: 2ms (expected ~100ms)

at android.opengl.cts.EglSurfacesTest.testFenceSync(EglSurfacesTest.java:234)
```

## 現象描述
`eglClientWaitSync()` 在 fence 尚未 signal 時，應該等待到 timeout，
但卻立即返回 `EGL_CONDITION_SATISFIED`。

## 提示
- timeout 參數單位是 nanoseconds
- 問題可能出在 timeout 值的單位轉換
- 追蹤 timeout 參數從 API 到驅動的傳遞
