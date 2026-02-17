# Q001: OpenGL ES Version Mismatch

## CTS Test
`android.opengl.cts.OpenGlEsVersionTest#testOpenGlEsVersion`

## Failure Log
```
junit.framework.AssertionFailedError: GL_VERSION string doesn't match 
ActivityManager major version (check ro.opengles.version property)
expected:<3> but was:<2>

at android.opengl.cts.OpenGlEsVersionTest.verifyGlVersionString(OpenGlEsVersionTest.java:276)
at android.opengl.cts.OpenGlEsVersionTest.testOpenGlEsVersion(OpenGlEsVersionTest.java:82)
```

## 現象描述
CTS 測試報告 GL_VERSION 字串回報的 major version 與 ActivityManager 回報的版本不一致。
系統配置顯示支援 OpenGL ES 3.2，但 GL 版本字串卻顯示 2.x。

## 提示
- 此測試檢查 `ro.opengles.version` 系統屬性與實際 GL 版本字串是否一致
- GL 版本字串格式應為 "OpenGL ES(-CM)? X.Y"
- 問題出在版本字串的生成邏輯
