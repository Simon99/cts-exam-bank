# Q004: glGetError Returns Wrong Error Code

## CTS Test
`android.opengl.cts.ProgramTest#test_glAttachShader_program`

## Failure Log
```
junit.framework.AssertionFailedError: 
expected:<1282> but was:<0>

at android.opengl.cts.ProgramTest.test_glAttachShader_program(ProgramTest.java:38)
```

## 現象描述
測試預期 `glGetError()` 應該返回 `GL_INVALID_OPERATION` (1282)，
但實際返回了 0 (`GL_NO_ERROR`)。

測試故意傳入無效參數給 `glAttachShader()`，期望觸發錯誤，但錯誤沒有被正確回報。

## 提示
- GL_INVALID_OPERATION = 0x0502 = 1282
- GL_NO_ERROR = 0
- 問題可能出在 error 清除的時機
