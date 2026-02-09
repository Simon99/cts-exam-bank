# Q006: EGL Object Reference Not Tracked

## CTS Test
`android.opengl.cts.EglContextTest#testContextDestroy`

## Failure Log
```
junit.framework.AssertionFailedError: EGL context should be invalid after destroy

eglMakeCurrent with destroyed context succeeded when it should fail
Expected: EGL_BAD_CONTEXT
Actual: EGL_SUCCESS

at android.opengl.cts.EglContextTest.testContextDestroy(EglContextTest.java:198)
```

## 現象描述
已銷毀的 EGL context 仍然可以被使用。
`eglDestroyContext()` 後，使用該 context 的操作應該失敗。

## 提示
- EGL object 需要被追蹤以驗證有效性
- 檢查 object 的添加/移除邏輯
- 問題可能出在 destroy 後的 object tracking
