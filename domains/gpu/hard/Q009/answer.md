# Q009 Answer: HDR Metadata Not Applied to Display

## 問題根因
在 `egl_object.cpp` 的 `getSmpte2086Metadata()` 函數中，luminance 值的轉換存在問題。

EGL 規範中，luminance 使用與色度值不同的 scaling：
- 色度值 (chromaticity)：實際值 × 50000
- 亮度值 (luminance)：實際值 × 10000

但代碼中對所有值都使用了 `EGL_METADATA_SCALING_EXT` (50000)，
導致 luminance 被錯誤縮放。

## Bug 位置
`frameworks/native/opengl/libs/EGL/egl_object.cpp` - `getSmpte2086Metadata()` 函數

## 關鍵代碼分析
```cpp
// 問題代碼 - luminance 使用了錯誤的 scaling factor
EGLBoolean egl_surface_t::getSmpte2086Metadata(android_smpte2086_metadata& metadata) const {
    // 色度值 - 使用 50000 scaling 是正確的
    metadata.displayPrimaryRed.x = static_cast<float>(egl_smpte2086_metadata.displayPrimaryRed.x) /
            EGL_METADATA_SCALING_EXT;  // 50000, 正確
    // ...
    
    // 亮度值 - 也使用了 50000，但應該使用 10000
    metadata.maxLuminance =
            static_cast<float>(egl_smpte2086_metadata.maxLuminance) / EGL_METADATA_SCALING_EXT;
    // BUG: 1000 nits × 10000 = 10000000，除以 50000 = 200 nits (錯誤)
    // 實際更糟：如果 maxLuminance 存的是 10000000，除以 50000 會 overflow
}
```

## EGL 規範說明
根據 EGL_EXT_surface_SMPTE2086_metadata 規範：
- Chromaticity (x, y)：scaled by 50000
- Max/Min Luminance：scaled by 10000

需要為 luminance 使用正確的 scaling constant。

## 修復方式
```cpp
// 定義正確的 luminance scaling
#define EGL_LUMINANCE_SCALING_EXT 10000

EGLBoolean egl_surface_t::getSmpte2086Metadata(android_smpte2086_metadata& metadata) const {
    // 色度值使用 50000
    metadata.displayPrimaryRed.x = static_cast<float>(egl_smpte2086_metadata.displayPrimaryRed.x) /
            EGL_METADATA_SCALING_EXT;
    // ... 其他色度值 ...
    
    // 亮度值使用 10000
    metadata.maxLuminance =
            static_cast<float>(egl_smpte2086_metadata.maxLuminance) / EGL_LUMINANCE_SCALING_EXT;
    metadata.minLuminance =
            static_cast<float>(egl_smpte2086_metadata.minLuminance) / EGL_LUMINANCE_SCALING_EXT;
    
    return EGL_TRUE;
}
```

## 調試步驟
1. 在 `setSmpte2086Attribute()` 中 log 存入的原始值
2. 在 `getSmpte2086Metadata()` 中 log 轉換前後的值
3. 使用 `dumpsys SurfaceFlinger` 查看 HDR metadata
4. 比較 EGL 規範中的 scaling 要求

## 相關知識
- SMPTE ST 2086 定義了 mastering display 的色域和亮度
- HDR 內容需要正確的 metadata 才能正確 tone mapping
- EGL 使用整數存儲，需要 scaling 來表示小數
- Luminance 範圍通常是 0.0001 到 10000 nits

## 難度說明
**Hard** - 需要理解 HDR metadata 規範和 EGL 擴展的數值表示。
問題表現為非顯而易見的精度損失，需要追蹤完整的數據流。
