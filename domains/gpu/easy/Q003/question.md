# Q003: EGL Bad Display Error on Initialization

## CTS Test
`android.opengl.cts.EglConfigTest#testEglConfigs`

## Failure Log
```
junit.framework.AssertionFailedError: eglInitialize failed with error: EGL_BAD_DISPLAY
EGL error: 0x3008

at android.opengl.cts.EglConfigTest.testEglConfigs(EglConfigTest.java:78)
```

## 現象描述
在進行 EGL 配置測試時，`eglInitialize()` 返回 `EGL_BAD_DISPLAY` 錯誤。
設備應該能夠正常初始化 EGL display。

## 提示
- EGL_BAD_DISPLAY (0x3008) 表示傳入的 display 無效
- 檢查 display 驗證邏輯
- 問題可能出在 display pointer 的驗證條件
