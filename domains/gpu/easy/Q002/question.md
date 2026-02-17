# Q002: EGL Extension Missing from Required List

## CTS Test
`android.opengl.cts.OpenGlEsVersionTest#testRequiredEglExtensions`

## Failure Log
```
junit.framework.AssertionFailedError: EGL Extension required by CDD section 7.1.4 missing: 
EGL_KHR_wait_sync

at android.opengl.cts.OpenGlEsVersionTest.testRequiredEglExtensions(OpenGlEsVersionTest.java:225)
```

## 現象描述
CTS 測試報告必需的 EGL extension `EGL_KHR_wait_sync` 不存在於 extension 字串中。
但驅動實際上支援此 extension。

## 提示
- CDD 7.1.4.1/C-6-1 要求特定 EGL extensions 必須可用
- Extension 字串是在 EGL 初始化時組合的
- 問題可能出在 extension 字串的拼接邏輯
