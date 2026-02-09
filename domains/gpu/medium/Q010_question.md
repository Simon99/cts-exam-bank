# Q010: GL Hooks Not Set for New Thread

## CTS Test
`android.opengl.cts.EglContextTest#testMultithreadedRendering`

## Failure Log
```
FATAL EXCEPTION: RenderThread-2
Process: android.opengl.cts, PID: 12345

java.lang.UnsatisfiedLinkError: No implementation found for 
void android.opengl.GLES20.glClear(int)

Rendering works in main thread but fails in worker thread

at android.opengl.GLES20.glClear(Native Method)
at android.opengl.cts.EglContextTest$RenderTask.run(EglContextTest.java:234)
```

## 現象描述
在新線程中進行 GL 操作失敗，顯示找不到 GL 函數實現。
主線程正常工作，但 worker thread 中的相同操作失敗。

## 提示
- GL hooks 是 thread-local 的
- 需要在新線程使用 GL 前設置 hooks
- 問題可能出在 makeCurrent 時的 hooks 設置
