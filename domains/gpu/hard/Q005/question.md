# Q005: GPU Memory Corruption on Context Switch

## CTS Test
`android.opengl.cts.EglContextTest#testMultiContextRendering`

## Failure Log
```
junit.framework.AssertionFailedError: Rendering corruption detected after context switch

Context A renders red quad at (0,0)
Context B renders blue quad at (100,100)
Switch back to Context A

Expected: Red quad at (0,0) still visible
Actual: Random pixels/corruption at (0,0)

Framebuffer content corrupted when switching between contexts

at android.opengl.cts.EglContextTest.testMultiContextRendering(EglContextTest.java:312)
```

## 現象描述
在多個 GL context 之間切換時，framebuffer 內容被破壞。
這影響多視窗渲染和 picture-in-picture 功能。

## 提示
- Context switch 涉及 GPU state 的保存和恢復
- 問題可能出在 makeCurrent 時的 flush/finish 操作
- 需要追蹤 context state machine
- 涉及 EGL display、context、surface 三者的交互
