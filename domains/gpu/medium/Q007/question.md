# Q007: Shader Cache Not Working

## CTS Test
`android.opengl.cts.ProgramTest#testShaderCompilePerformance`

## Failure Log
```
junit.framework.AssertionFailedError: Shader cache not functioning

Second compile should be faster than first compile
First compile time: 150ms
Second compile time: 148ms (expected < 50ms with cache hit)

at android.opengl.cts.ProgramTest.testShaderCompilePerformance(ProgramTest.java:89)
```

## 現象描述
Shader 編譯沒有利用 cache。第二次編譯同樣的 shader 應該更快（cache hit），
但實際時間與第一次相近。

## 提示
- Shader cache 由 egl_cache 模組管理
- Cache 的 key 基於 shader 內容
- 追蹤 cache 的 set/get 操作
