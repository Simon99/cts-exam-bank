# Q002: MSAA Config Not Available When Forced

## CTS Test
`android.opengl.cts.EglConfigTest#testMsaaConfig`

## Failure Log
```
junit.framework.AssertionFailedError: MSAA 4x config should be available when 
debug.egl.force_msaa is set to true

Expected EGL_SAMPLES >= 4, got: 1
EGL_SAMPLE_BUFFERS expected: 1, got: 0

at android.opengl.cts.EglConfigTest.testMsaaConfig(EglConfigTest.java:167)
```

## 現象描述
當設置 `debug.egl.force_msaa=true` 時，`eglChooseConfig()` 應該返回支援 4x MSAA 的配置，
但實際返回的配置沒有 MSAA 支援。

## 提示
- Force MSAA 邏輯在 eglChooseConfig 的 wrapper 中
- 需要追蹤 attrib_list 的修改過程
- 檢查 MSAA attrib 的插入位置
