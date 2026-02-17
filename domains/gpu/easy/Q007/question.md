# Q007: Wide Color Extension Not Advertised

## CTS Test
`android.opengl.cts.OpenGlEsVersionTest#testRequiredEglExtensionsForWideColorDisplay`

## Failure Log
```
junit.framework.AssertionFailedError: EGL extension required by CDD section 7.1.4.5 missing: 
EGL_EXT_gl_colorspace_display_p3

at android.opengl.cts.OpenGlEsVersionTest.testRequiredEglExtensionsForWideColorDisplay(OpenGlEsVersionTest.java:289)
```

## 現象描述
設備宣告支援 wide color display，但 CTS 測試報告缺少必需的 Display P3 色彩空間 extension。
驅動本身支援此功能。

## 提示
- Wide color 功能需要系統屬性 `ro.surface_flinger.has_wide_color_display`
- Extension 的添加受到多個條件控制
- 檢查 wide color extension 添加的條件判斷
