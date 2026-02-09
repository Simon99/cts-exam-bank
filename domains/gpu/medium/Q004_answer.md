# Q004 Answer: GL Extension Forwarding Broken

## 問題根因
在 `gl2.cpp` 的 `glGetStringi()` wrapper 中，調用 platform 函數時使用了錯誤的參數順序，
導致 index 和 name 被交換。

## Bug 位置
1. `frameworks/native/opengl/libs/GLES2/gl2.cpp` - glGetStringi wrapper
2. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - platform 函數定義

## 修復方式
```cpp
// 錯誤的代碼 (gl2.cpp)
const GLubyte * glGetStringi(GLenum name, GLuint index) {
    egl_connection_t* const cnx = egl_get_connection();
    return cnx->platform.glGetStringi(index, name);  // BUG: 參數順序錯誤
}

// 正確的代碼
const GLubyte * glGetStringi(GLenum name, GLuint index) {
    egl_connection_t* const cnx = egl_get_connection();
    return cnx->platform.glGetStringi(name, index);
}
```

## 調試步驟
1. 在 `glGetStringi()` 添加 log 記錄參數
2. 比較傳入參數和傳遞給驅動的參數
3. 驗證 name 應為 GL_EXTENSIONS (0x1F03)，index 為數字

## 相關知識
- GL_EXTENSIONS 作為 name 傳入
- index 是 extension 的索引號
- 參數順序錯誤是常見的 API wrapper bug

## 難度說明
**Medium** - fail log 顯示特定 API 問題，需要追蹤參數傳遞過程。
