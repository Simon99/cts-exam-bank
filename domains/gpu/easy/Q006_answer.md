# Q006 Answer: EGL Config Count Always Zero

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglGetConfigsImpl()` 函數中，
初始化 `*num_config = 0` 後，在成功呼叫驅動函數後沒有更新這個值。
驅動的結果被忽略了。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp`

## 修復方式
```cpp
// 錯誤的代碼
EGLBoolean eglGetConfigsImpl(EGLDisplay dpy, EGLConfig* configs, EGLint config_size,
                             EGLint* num_config) {
    // ...
    EGLBoolean res = EGL_FALSE;
    *num_config = 0;
    
    EGLint driverNumConfig;
    res = cnx->egl.eglGetConfigs(dp->disp.dpy, configs, config_size, &driverNumConfig);
    // BUG: 忘記設置 *num_config = driverNumConfig
    return res;
}

// 正確的代碼 - 應該將驅動返回的值傳遞給調用者
```

## 相關知識
- eglGetConfigs 使用 out 參數返回 config 數量
- 驅動層和 wrapper 層都有自己的 num_config 變數
- wrapper 層需要正確傳遞驅動的結果

## 難度說明
**Easy** - fail log 顯示 config 數量為 0，檢查 eglGetConfigs 實現即可發現遺漏的賦值。
