# Q009: HDR Metadata Not Applied to Display

## CTS Test
`android.opengl.cts.EglHdrMetadataTest#testSmpte2086MetadataApplied`

## Failure Log
```
FAILED: android.opengl.cts.EglHdrMetadataTest#testSmpte2086MetadataApplied

java.lang.AssertionError: HDR metadata not correctly applied to surface

Expected display luminance: 1000.0 nits
Actual display luminance: 0.00005 nits (underflow detected)

EGL Surface Attributes Set:
  EGL_SMPTE2086_MAX_LUMINANCE_EXT: 10000000 (scaled value)
  
Native Window Metadata Received:
  maxLuminance: 0.00005 (incorrect conversion)

W/egl_surface: getSmpte2086Metadata: luminance value appears incorrect
E/SurfaceFlinger: HDR content detected but metadata values invalid
```

## 現象描述
應用程式設置 HDR SMPTE 2086 metadata 後，顯示器未正確進入 HDR 模式。
max luminance 值出現嚴重的精度損失，從 1000 nits 變成接近 0 的值。
問題出在 EGL metadata 到 native window 的轉換過程中。

## 提示
- EGL 使用 `EGL_METADATA_SCALING_EXT` (50000) 進行縮放
- SMPTE 2086 metadata 包含色域和亮度資訊
- 需要追蹤 `egl_object.cpp` 中的 metadata 處理
- 關注 `setSmpte2086Attribute()` 和 `getSmpte2086Metadata()` 的關係
- 問題可能涉及整數/浮點數轉換
