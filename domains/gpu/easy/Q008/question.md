# Q008: eglQueryString Returns Null for Extensions

## CTS Test
`android.opengl.cts.OpenGlEsVersionTest#testRequiredExtensions`

## Failure Log
```
java.lang.NullPointerException: Attempt to invoke virtual method 
'boolean java.lang.String.contains(java.lang.CharSequence)' on a null object reference

at android.opengl.cts.OpenGlEsVersionTest.hasExtension(OpenGlEsVersionTest.java:298)
at android.opengl.cts.OpenGlEsVersionTest.testRequiredExtensions(OpenGlEsVersionTest.java:103)
```

## 現象描述
測試在檢查 extension 時發生 NullPointerException，
表示 `eglQueryString(display, EGL_EXTENSIONS)` 返回了 null。

## 提示
- eglQueryString 應返回有效的字串指針
- 問題可能出在 name 參數的處理
- 檢查 EGL_EXTENSIONS 常數的比較
