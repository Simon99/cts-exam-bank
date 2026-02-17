# Q003 Answer: ANGLE Backend Selection Broken

## 問題根因
ANGLE backend 選擇涉及：
1. `GraphicsEnv.cpp` - 讀取系統配置
2. `egl_display.cpp` - 構建 ANGLE platform attributes
3. `egl_platform_entries.cpp` - 調用 eglGetPlatformDisplay
4. ANGLE library - 根據 attributes 選擇 backend

問題出在 `egl_display.cpp` 的 `getPlatformDisplayAngle()` 中，
EGL_PLATFORM_ANGLE_TYPE 的值被硬編碼為 OpenGL ES 而不是從配置讀取。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - platform type 設置
2. `frameworks/native/libs/graphicsenv/GraphicsEnv.cpp` - 配置讀取
3. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - display 創建

## 修復方式
```cpp
// 錯誤的代碼 (egl_display.cpp)
static EGLDisplay getPlatformDisplayAngle(...) {
    // ...
    attrs.push_back(EGL_PLATFORM_ANGLE_TYPE_ANGLE);
    attrs.push_back(EGL_PLATFORM_ANGLE_TYPE_OPENGLES_ANGLE);  // BUG: hardcoded
    // ...
}

// 正確的代碼
static EGLDisplay getPlatformDisplayAngle(...) {
    // ...
    attrs.push_back(EGL_PLATFORM_ANGLE_TYPE_ANGLE);
    // Use Vulkan unless explicitly requesting GLES
    if (GraphicsEnv::getInstance().getAngleBackend() == "opengles") {
        attrs.push_back(EGL_PLATFORM_ANGLE_TYPE_OPENGLES_ANGLE);
    } else {
        attrs.push_back(EGL_PLATFORM_ANGLE_TYPE_VULKAN_ANGLE);
    }
    // ...
}
```

## 調試步驟
1. 檢查 GraphicsEnv 中的 ANGLE 配置
2. Log eglGetPlatformDisplay 收到的 attributes
3. 追蹤 EGL_PLATFORM_ANGLE_TYPE 的設置來源
4. 驗證 ANGLE 內部選擇的 backend

## 相關知識
- ANGLE 是 Google 的 GL-on-Vulkan/D3D 實現
- Backend 選擇影響性能和兼容性
- Vulkan backend 通常是首選

## 難度說明
**Hard** - 涉及 3 個檔案跨模組交互，需要理解 ANGLE 架構。
