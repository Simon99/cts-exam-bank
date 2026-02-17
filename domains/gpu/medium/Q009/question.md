# Q009: Presentation Time Not Applied

## CTS Test
`android.opengl.cts.GLSurfaceViewTest#testPresentationTime`

## Failure Log
```
junit.framework.AssertionFailedError: eglPresentationTimeANDROID not taking effect

Set presentation time: 1000000000 ns (1 second in future)
Actual presentation timestamp: immediate (within 16ms)

Frame should have been delayed but was presented immediately

at android.opengl.cts.GLSurfaceViewTest.testPresentationTime(GLSurfaceViewTest.java:278)
```

## 現象描述
`eglPresentationTimeANDROID()` 設置的呈現時間沒有生效。
Frame 應該在指定時間呈現，但實際上立即呈現了。

## 提示
- presentation time 會傳遞給 SurfaceFlinger
- 需要追蹤時間戳從 EGL 到 native window 的傳遞
- 問題可能出在 surface 的 timestamp 設置
