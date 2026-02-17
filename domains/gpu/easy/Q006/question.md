# Q006: EGL Config Count Always Zero

## CTS Test
`android.opengl.cts.EglConfigTest#testEglGetConfigs`

## Failure Log
```
junit.framework.AssertionFailedError: No EGL configs found
Expected at least 1 config but got: 0

at android.opengl.cts.EglConfigTest.testEglGetConfigs(EglConfigTest.java:92)
```

## 現象描述
`eglGetConfigs()` 返回 config 數量為 0，
但設備應該至少有一個有效的 EGL config。

## 提示
- eglGetConfigs 的第四個參數 num_config 應該接收實際的 config 數量
- 檢查 num_config 參數的處理
- 問題可能出在參數驗證後的早期返回
