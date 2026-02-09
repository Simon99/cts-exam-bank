# Q002 Answer: Protected Content Rendering Fails

## 問題根因
Protected content 需要多個元件協同：
1. `egl_platform_entries.cpp` - 創建 protected context/surface
2. `egl_object.cpp` - 存儲 protected flag
3. `egl_display.cpp` - 傳遞 protected attribute 給驅動
4. Buffer allocation 需要知道是 protected

問題出在 `egl_object.cpp` 的 surface 對象中，protected flag 沒有被正確存儲，
導致後續創建 buffer 時沒有使用 protected heap。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_object.cpp` - surface flag 存儲
2. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - surface 創建
3. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - attribute 傳遞

## 修復方式
```cpp
// 錯誤的代碼 (egl_object.cpp)
egl_surface_t::egl_surface_t(egl_display_t* dpy, EGLConfig config,
                             EGLNativeWindowType win, EGLSurface surface,
                             const EGLint* attrib_list) 
    : egl_object_t(dpy), surface(surface), config(config), win(win) {
    // BUG: 沒有解析 protected attribute
    // isProtected = parseProtectedAttribute(attrib_list);
}

// 正確的代碼
egl_surface_t::egl_surface_t(...) : ... {
    isProtected = false;
    if (attrib_list) {
        for (const EGLint* attr = attrib_list; *attr != EGL_NONE; attr += 2) {
            if (attr[0] == EGL_PROTECTED_CONTENT_EXT && attr[1] == EGL_TRUE) {
                isProtected = true;
                break;
            }
        }
    }
}
```

## 調試步驟
1. 在 surface 創建時 log protected attribute
2. 追蹤 flag 在 egl_surface_t 中的存儲
3. 檢查 buffer allocation 時的 usage flags
4. 驗證 gralloc 收到的 allocation 參數

## 相關知識
- Protected content 用於 DRM 保護的媒體
- 需要硬體級別的保護（TEE）
- 整個渲染 pipeline 必須是 protected 的

## 難度說明
**Hard** - 涉及 3+ 個檔案，需要理解 protected content 的完整路徑。
