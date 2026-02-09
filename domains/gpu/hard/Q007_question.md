# Q007: GPU Driver Timeout on Complex Shader

## CTS Test
`android.opengl.cts.RendererTwelveShaderTest#testComplexShader`

## Failure Log
```
junit.framework.AssertionFailedError: Shader execution timed out

GL error after draw call: GL_CONTEXT_LOST (0x0507)

GPU hang detected. Device watchdog triggered:
[   45.123456] kgsl kgsl-3d0: GPU hang detected
[   45.123789] kgsl kgsl-3d0: Dumping snapshot...

Logcat shows:
E/Adreno: TIMEOUT waiting for ringbuffer to empty
E/EGL: GPU reset occurred, context is lost

at android.opengl.cts.RendererTwelveShaderTest.testComplexShader(RendererTwelveShaderTest.java:89)
```

## 現象描述
複雜 shader 執行時 GPU hang，觸發設備 watchdog。
GPU driver 超時導致 context lost。

## 提示
- GPU timeout 涉及 driver 和 EGL 的 recovery 機制
- 問題可能是 shader 太複雜，也可能是 driver 設置問題
- 需要檢查 EGL robustness extension 的處理
- 涉及 context 創建時的 robustness attribute
