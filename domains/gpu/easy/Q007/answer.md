# Q007 Answer: Wide Color Extension Not Advertised

## 問題根因
在 `egl_display.cpp` 的 `initialize()` 函數中，
添加 wide color extensions 的條件判斷使用了錯誤的邏輯運算符。
使用了 `||` 而不是 `&&`，導致只要有一個條件為 false 就不添加。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_display.cpp`

## 修復方式
```cpp
// 錯誤的代碼
if (wideColorBoardConfig || hasColorSpaceSupport) {  // BUG: 應該是 &&
    mExtensionString.append(
            "EGL_EXT_gl_colorspace_scrgb EGL_EXT_gl_colorspace_scrgb_linear "
            "EGL_EXT_gl_colorspace_display_p3_linear EGL_EXT_gl_colorspace_display_p3 "
            ...);
}

// 正確的代碼
if (wideColorBoardConfig && hasColorSpaceSupport) {
    // ...
}
```

## 相關知識
- Wide color 功能需要：硬體支援 + 驅動 colorspace extension 支援
- 兩個條件必須同時滿足（&&）才能啟用
- CDD 7.1.4.5/C-1-5 對 wide color 設備有特定要求

## 難度說明
**Easy** - fail log 指出缺少的 extension，搜尋 extension 添加邏輯即可發現條件錯誤。
