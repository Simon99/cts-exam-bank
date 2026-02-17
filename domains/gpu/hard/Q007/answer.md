# Q007 Answer: GPU Driver Timeout on Complex Shader

## 問題根因
GPU 復原機制涉及：
1. `egl_platform_entries.cpp` - context 創建和 robustness 支援
2. `egl_display.cpp` - context lost 處理
3. `egl_object.cpp` - context 狀態追蹤
4. Kernel driver - GPU reset handling

問題出在 `egl_platform_entries.cpp` 的 `eglCreateContextImpl()` 中，
當應用請求 `EGL_CONTEXT_OPENGL_ROBUST_ACCESS_EXT` 時，
attribute 被錯誤地過濾掉，導致驅動沒有啟用 GPU reset notification。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - context 創建
2. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - error recovery
3. `frameworks/native/opengl/libs/EGL/egl_object.cpp` - context 狀態

## 修復方式
```cpp
// 錯誤的代碼 (egl_platform_entries.cpp)
EGLContext eglCreateContextImpl(..., const EGLint* attrib_list) {
    // Process attributes
    std::vector<EGLint> filteredAttribs;
    for (const EGLint* attr = attrib_list; *attr != EGL_NONE; attr += 2) {
        // BUG: Robustness attribute filtered out
        if (attr[0] == EGL_CONTEXT_OPENGL_ROBUST_ACCESS_EXT) {
            continue;  // Skip robustness attribute
        }
        filteredAttribs.push_back(attr[0]);
        filteredAttribs.push_back(attr[1]);
    }
    // ...
}

// 正確的代碼 - 應該保留 robustness attribute
```

## 調試步驟
1. 檢查 context 創建時的 attrib_list
2. 追蹤 attribute 傳遞給驅動的過程
3. 驗證 EGL_CONTEXT_OPENGL_ROBUST_ACCESS_EXT 是否生效
4. 檢查 glGetGraphicsResetStatus() 的返回值

## 相關知識
- GPU robustness 允許應用處理 GPU hang
- 沒有 robustness，GPU reset 會導致整個 context 丟失
- 這是 games 和 professional apps 的重要功能

## 難度說明
**Hard** - 涉及 GPU recovery 機制，跨越多個檔案，需要理解 robustness extension。
