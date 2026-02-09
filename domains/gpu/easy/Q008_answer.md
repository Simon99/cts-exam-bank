# Q008 Answer: eglQueryString Returns Null for Extensions

## 問題根因
在 `egl_platform_entries.cpp` 的 `eglQueryStringImpl()` 函數中，
對 `EGL_EXTENSIONS` 的判斷使用了錯誤的常數值。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp`

## 修復方式
```cpp
// 錯誤的代碼（在 eglQueryStringImpl 中）
case 0x3054:  // BUG: 應該是 EGL_EXTENSIONS (0x3055)
    return dp->mExtensionString.c_str();

// 正確的代碼
case EGL_EXTENSIONS:  // 0x3055
    return dp->mExtensionString.c_str();
```

## 相關知識
- EGL_EXTENSIONS = 0x3055
- EGL_VENDOR = 0x3053
- EGL_VERSION = 0x3054
- 使用魔數而非常數名是 bug 的常見來源

## 難度說明
**Easy** - NPE 表示返回 null，搜尋 eglQueryString 的 EGL_EXTENSIONS 處理即可發現常數錯誤。
