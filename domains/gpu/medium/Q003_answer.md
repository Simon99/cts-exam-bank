# Q003 Answer: Color Space Conversion Wrong for HDR Content

## 問題根因
在 `egl_platform_entries.cpp` 的 `dataSpaceFromEGLColorSpace()` 函數中，
BT2020_PQ 和 BT2020_LINEAR 的處理順序錯誤，導致 PQ 被當作 LINEAR 處理。

## Bug 位置
1. `frameworks/native/opengl/libs/EGL/egl_platform_entries.cpp` - colorspace 映射
2. `frameworks/native/opengl/libs/EGL/egl_display.cpp` - HDR extension 檢查

## 修復方式
```cpp
// 錯誤的代碼
} else if (colorspace == EGL_GL_COLORSPACE_BT2020_PQ_EXT) {
    return HAL_DATASPACE_BT2020_LINEAR;  // BUG: 應該是 BT2020_PQ
} else if (colorspace == EGL_GL_COLORSPACE_BT2020_LINEAR_EXT) {
    return HAL_DATASPACE_BT2020_PQ;      // BUG: 應該是 BT2020_LINEAR

// 正確的代碼
} else if (colorspace == EGL_GL_COLORSPACE_BT2020_PQ_EXT) {
    return HAL_DATASPACE_BT2020_PQ;
} else if (colorspace == EGL_GL_COLORSPACE_BT2020_LINEAR_EXT) {
    return HAL_DATASPACE_BT2020_LINEAR;
```

## 調試步驟
1. 在 `dataSpaceFromEGLColorSpace()` 添加 log 記錄輸入輸出
2. 創建 HDR surface 並檢查 dataspace
3. 比較預期和實際的 dataspace 值

## 相關知識
- BT.2020 是 HDR 的廣色域標準
- PQ (Perceptual Quantizer) 是 HDR 的傳輸函數
- colorspace 映射錯誤會導致顏色失真

## 難度說明
**Medium** - 需要理解 colorspace/dataspace 概念並追蹤映射邏輯。
