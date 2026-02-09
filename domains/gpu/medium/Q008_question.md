# Q008: EGL Image Creation Memory Leak

## CTS Test
`android.opengl.cts.EglSurfacesTest#testImageCreationDestruction`

## Failure Log
```
junit.framework.AssertionFailedError: Memory leak detected in EGLImage operations

After 100 create/destroy cycles:
Expected memory delta: ~0 MB
Actual memory delta: +150 MB

Native heap growth indicates unreleased resources

at android.opengl.cts.EglSurfacesTest.testImageCreationDestruction(EglSurfacesTest.java:312)
```

## 現象描述
重複創建和銷毀 EGLImage 導致記憶體持續增長。
銷毀操作應該釋放所有相關資源。

## 提示
- EGLImage 關聯 ANativeWindowBuffer
- 需要追蹤 buffer 的引用計數
- 問題可能出在 destroy 時的資源釋放
