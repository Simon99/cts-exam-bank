# Q010: EGL Terminate Leaks Reference Count

## CTS Test
`android.opengl.cts.EglContextTest#testMultipleInitTerminate`

## Failure Log
```
junit.framework.AssertionFailedError: 
EGL display should be terminated but refs count is still: 1
Expected egl_get_init_count() to return 0 after terminate

at android.opengl.cts.EglContextTest.testMultipleInitTerminate(EglContextTest.java:87)
```

## 現象描述
在調用 `eglTerminate()` 後，display 的引用計數仍然為 1，
表示 terminate 沒有正確減少引用計數。

## 提示
- EGL display 使用引用計數管理生命週期
- eglInitialize 增加計數，eglTerminate 減少計數
- 檢查 terminate 函數中的引用計數操作
