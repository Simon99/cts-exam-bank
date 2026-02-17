# DIS-H004: Display Mode Alternative Refresh Rates 對稱性錯誤

## 難度：Hard ⭐⭐⭐

## 失敗的 CTS 測試

```
android.display.cts.DisplayTest#testGetSupportedModesOnDefaultDisplay
```

## 測試目的

此測試驗證 **alternativeRefreshRates 的對稱性**：如果 mode A 列出 mode B 作為 alternative，則 mode B 也必須列出 mode A。

## 背景知識

### Alternative Refresh Rates

Android 設備可能支援多個 display modes（如 60Hz、90Hz、120Hz）。對於同解析度的 modes，系統會建立 alternative 關係：

```
Mode 1 (60Hz)                    Mode 2 (90Hz)
├── alternativeRefreshRates      ├── alternativeRefreshRates
│   └── [90.0]          ←→      │   └── [60.0]
```

### 對稱性要求

```
如果 A.alternatives 包含 B
則 B.alternatives 必須包含 A
```

這是 CTS 測試的核心驗證邏輯。

## 相關程式碼位置

```
frameworks/base/services/core/java/com/android/server/display/
└── LocalDisplayAdapter.java
    └── updateDisplayModesLocked() (約 310-360 行)
```

## 測試失敗訊息

```
java.lang.AssertionError: Expected {id=1, fps=60.0, alternativeRefreshRates=[90.0]} 
to be listed as alternative refresh rate of 
{id=2, fps=90.0, alternativeRefreshRates=[]}
```

## 提示

1. **理解 alternative 的建立邏輯**：在哪裡決定哪些 modes 是 alternatives？
2. **對稱性條件**：`j != i` 的條件是否正確？
3. **迴圈索引**：i 和 j 的關係會影響結果嗎？

## 你的任務

找出為什麼 alternativeRefreshRates 的對稱性被破壞。

---

**提交格式**：指出 bug 所在的程式碼位置，解釋 bug 的成因，並提供修復方案。
