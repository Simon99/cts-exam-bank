# Q004: GL Extension Forwarding Broken

## CTS Test
`android.opengl.cts.OpenGlEsVersionTest#testRequiredExtensions`

## Failure Log
```
junit.framework.AssertionFailedError: OpenGL ES version 3.1+ is missing extension 
OES_shader_image_atomic

Extension exists in driver but not accessible via glGetStringi()
glGetStringi(GL_EXTENSIONS, N) returns NULL for valid index

at android.opengl.cts.OpenGlEsVersionTest.testRequiredExtensions(OpenGlEsVersionTest.java:115)
```

## 現象描述
驅動支援 `OES_shader_image_atomic` extension，但通過 `glGetStringi()` 查詢時返回 NULL。
`glGetString(GL_EXTENSIONS)` 可以看到該 extension。

## 提示
- glGetString 和 glGetStringi 是兩個不同的查詢方式
- glGetStringi 用於按索引查詢單個 extension
- 問題可能出在 extension forwarding 機制
