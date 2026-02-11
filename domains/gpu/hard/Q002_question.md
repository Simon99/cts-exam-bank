# Q002: FPS 報告只回報部分圖層

## CTS Test
`cts/hostsidetests/graphics/gpuprofiling/CtsGpuProfilingDataTest`

## Failure Log
```
junit.framework.AssertionFailedError: FPS callback not received for registered task

Test scenario:
- App with multiple nested view layers registered for FPS callback
- Parent view layer reported FPS correctly
- Child view layers in same task: NO FPS CALLBACK

Expected: All layers in task hierarchy should contribute to FPS calculation
Actual: Only top-level layers are included

FpsReporter state:
  - Registered listeners: 3
  - Tasks with FPS reported: 1 (expected: 3)
  - Layer traversal depth: 1 (expected: 4)

Nested task structure:
  TaskId=100: RootLayer
    └── TaskId=200: ChildLayer (MISSED)
        └── TaskId=300: GrandchildLayer (MISSED)

at android.graphics.cts.FpsListenerTest.testNestedTaskFpsReporting(FpsListenerTest.java:156)
```

## 現象描述
應用程式註冊 FPS Listener 後，只有最頂層的 Layer 被報告 FPS，
嵌套在內部的子 Layer（即使有不同的 TaskId）完全沒有收到 FPS 回報。
對於有複雜 View 階層的應用特別明顯。

## 提示
- FpsReporter 透過 traverse 遍歷 LayerHierarchy 收集需要報告的 task
- traverse callback 的返回值控制是否繼續深入遍歷子節點
- 問題可能出在遍歷邏輯的中斷條件

## 問題
這個 FPS 報告缺漏的根本原因是什麼？

A) FpsReporter 的 kMinDispatchDuration 設定太長，導致某些 task 被跳過
B) traverse 的 callback 返回 false 導致遍歷在第一層就停止，沒有訪問子節點
C) FrameTimeline.computeFps() 過濾掉了 nested layer 的 presentTime
D) seenTasks 集合沒有正確初始化，導致重複 taskId 被跳過
