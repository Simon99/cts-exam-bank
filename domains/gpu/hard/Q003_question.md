# Q003: ANGLE Backend Selection Broken

## CTS Test
`android.opengl.cts.EglAngleTest#testAngleBackendSelection`

## Failure Log
```
junit.framework.AssertionFailedError: ANGLE Vulkan backend not activated

System property ro.hardware.egl set to: angle
ANGLE_PREFER_ANGLE_GL_ES_BACKEND set to: false (Vulkan preferred)

Expected GL_RENDERER to contain: ANGLE (Vulkan)
Actual GL_RENDERER: ANGLE (OpenGL ES)

ANGLE is loading but selecting wrong backend

at android.opengl.cts.EglAngleTest.testAngleBackendSelection(EglAngleTest.java:156)
```

## 現象描述
系統配置要求使用 ANGLE 的 Vulkan backend，
但實際選擇了 OpenGL ES backend。

## 提示
- ANGLE backend 選擇涉及多個層次：
  - GraphicsEnv 讀取系統屬性
  - egl_display 構建 platform attributes
  - ANGLE 接收 attributes 並選擇 backend
- 需要追蹤 platform type attribute 的傳遞
