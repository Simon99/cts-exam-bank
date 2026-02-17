# DIS-H002: Display Mode 替代刷新率對稱性漏洞

## 難度：Hard ⭐⭐⭐

## 失敗的 CTS 測試

```
android.display.cts.DisplayTest#testGetSupportedModesOnDefaultDisplay
```

## 測試目的

此測試驗證 **Display Mode 的替代刷新率（alternativeRefreshRates）必須形成對稱圖**。

如果 Mode A 說可以切換到 Mode B 的刷新率，那麼 Mode B 也必須說可以切換回 Mode A 的刷新率。這種對稱性確保了刷新率切換的一致性。

## 背景知識

### Display Mode 結構

```
Display.Mode
├── getModeId()                 → Mode 的唯一識別碼
├── getRefreshRate()            → 刷新率 (例如 60Hz, 90Hz)
├── getAlternativeRefreshRates()→ 可切換的替代刷新率陣列
└── getSupportedHdrTypes()      → 支援的 HDR 類型
```

### 替代刷新率的對稱性要求

```
┌─────────────────────────────────────────────────────────────┐
│              Alternative Refresh Rates 對稱性                │
├─────────────────────────────────────────────────────────────┤
│  Mode 1 (60Hz)                   Mode 2 (90Hz)              │
│  alternativeRefreshRates: [90]   alternativeRefreshRates: [60]│
│                                                              │
│           60 → 90 ✓                  90 → 60 ✓              │
│                      對稱！                                  │
├─────────────────────────────────────────────────────────────┤
│  如果 Mode 2 的 alternativeRefreshRates 被清空：             │
│                                                              │
│  Mode 1 (60Hz)                   Mode 2 (90Hz)              │
│  alternativeRefreshRates: [90]   alternativeRefreshRates: []│
│                                                              │
│           60 → 90 ✓                  90 → 60 ✗              │
│                      不對稱！                                │
└─────────────────────────────────────────────────────────────┘
```

## 相關程式碼位置

```
frameworks/base/services/core/java/com/android/server/display/
└── LogicalDisplay.java
    └── updateDisplayInfoLocked() (約 460-480 行)
        └── supportedModes 的複製邏輯
```

## 測試失敗訊息

```
java.lang.AssertionError: Could not find alternative display mode with refresh rate 60.0 for 
{id=2, width=1080, height=2400, fps=90.0, vsync=90.0, alternativeRefreshRates=[], supportedHdrTypes=[2, 3, 4]}.
All supported modes are [...]
```

## 提示

1. **觀察 Mode 結構**：注意 alternativeRefreshRates 陣列在不同 modes 中的內容
2. **複製邏輯**：supportedModes 是如何從 DeviceInfo 複製到 BaseDisplayInfo 的？
3. **條件處理**：是否有針對特定 mode 的特殊處理？
4. **對稱性**：如果只有部分 modes 的 alternativeRefreshRates 被修改，會發生什麼？

## 你的任務

找出為什麼 alternativeRefreshRates 的對稱性被破壞了。

---

**提交格式**：指出 bug 所在的程式碼位置，解釋 bug 的成因，並提供修復方案。
