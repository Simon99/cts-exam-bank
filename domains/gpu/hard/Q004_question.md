# Q004: Frame Timestamps Inconsistent

## CTS Test
`android.opengl.cts.GLSurfaceViewTest#testFrameTimestamps`

## Failure Log
```
junit.framework.AssertionFailedError: Frame timestamps inconsistent

Frame 1: compositeDeadline=100ms, compositeToPresentLatency=16ms
Frame 2: compositeDeadline=100ms, compositeToPresentLatency=16ms
Frame 3: compositeDeadline=100ms, compositeToPresentLatency=16ms

Problem: All frames report identical timestamps
Expected: Timestamps should increment per frame (16.6ms intervals at 60Hz)

eglGetCompositorTimingANDROID returns stale data

at android.opengl.cts.GLSurfaceViewTest.testFrameTimestamps(GLSurfaceViewTest.java:345)
```

## 現象描述
`eglGetCompositorTimingANDROID()` 返回的時間戳每幀都相同，
應該隨每幀遞增。這影響遊戲和視頻應用的幀節奏控制。

## 提示
- Frame timestamps 來自 SurfaceFlinger
- 涉及 EGL → Surface → SurfaceFlinger 的通訊
- 需要追蹤時間戳的更新機制
- 可能是查詢時沒有正確更新緩存的數據
