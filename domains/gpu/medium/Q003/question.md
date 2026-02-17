# Q003: Color Space Conversion Wrong for HDR Content

## CTS Test
`android.opengl.cts.OpenGlEsVersionTest#testRequiredEglExtensionsForHdrCapableDisplay`

## Failure Log
```
junit.framework.AssertionFailedError: HDR content displays with incorrect colors
BT2020 colorspace dataspace mapping verification failed

Expected dataspace: HAL_DATASPACE_BT2020_PQ
Actual dataspace: HAL_DATASPACE_BT2020_LINEAR

at android.opengl.cts.OpenGlEsVersionTest.testRequiredEglExtensionsForHdrCapableDisplay(OpenGlEsVersionTest.java:262)
```

## 現象描述
HDR 內容顯示顏色不正確。BT2020 PQ 色彩空間被錯誤地映射到 BT2020 LINEAR。

## 提示
- 色彩空間到 dataspace 的映射在 egl_platform_entries.cpp
- 問題在 `dataSpaceFromEGLColorSpace()` 函數
- 需要追蹤 EGL colorspace attrib 到 dataspace 的轉換
