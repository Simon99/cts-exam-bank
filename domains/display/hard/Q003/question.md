# DIS-H003: Display Mode 切換被靜默拒絕

## 難度：Hard ⭐⭐⭐

## 失敗的 CTS 測試

```
android.display.cts.DisplayTest#testModeSwitchOnPrimaryDisplay
```

## 測試目的

此測試驗證 **app 可以成功切換 display mode**。

Android 允許 app 透過 `WindowManager.LayoutParams.preferredDisplayModeId` 請求特定的 display mode。系統應該嘗試滿足這個請求（如果硬體支援）。

## 背景知識

### Display Mode 切換流程

```
┌─────────────────────────────────────────────────────────────┐
│                    Mode Switch 流程                          │
├─────────────────────────────────────────────────────────────┤
│  App 設置 preferredDisplayModeId                             │
│       ↓                                                      │
│  WindowManager 收集所有 window 的 mode 請求                  │
│       ↓                                                      │
│  DisplayModeDirector 決定最佳 mode                          │
│       ↓                                                      │
│  LogicalDisplay.setDesiredDisplayModeSpecsLocked()          │
│       ↓                                                      │
│  SurfaceFlinger 執行實際切換                                 │
│       ↓                                                      │
│  onDisplayChanged() 通知所有 listener                       │
└─────────────────────────────────────────────────────────────┘
```

### DesiredDisplayModeSpecs

```java
class DesiredDisplayModeSpecs {
    int baseModeId;           // 基礎 mode（決定解析度）
    RefreshRateRange primary; // 主要的 refresh rate 範圍
    RefreshRateRange appRequest; // App 請求的範圍
}
```

## 相關程式碼位置

```
frameworks/base/services/core/java/com/android/server/display/
└── LogicalDisplay.java
    └── setDesiredDisplayModeSpecsLocked() (約 738-745 行)
```

## 測試失敗訊息

```
java.lang.AssertionError: Mode switch timeout
    waited 5 seconds for display to change to mode: Mode{id=2, width=1080, height=2400, fps=90.0}
    but display stayed at: Mode{id=1, width=1080, height=2400, fps=60.0}
    at android.display.cts.DisplayTest.testSwitchToModeId(DisplayTest.java:792)
```

## 提示

1. **理解 mode 請求流程**：從 app 到 SurfaceFlinger 的資料流
2. **靜默失敗**：請求可能被接受但不執行
3. **條件判斷**：什麼情況下系統會拒絕 mode 切換？
4. **default vs requested**：比較 `defaultModeId` 和 `baseModeId` 可能有什麼問題？

## 你的任務

找出為什麼 display mode 切換請求沒有生效。

---

**提交格式**：指出 bug 所在的程式碼位置，解釋 bug 的成因，並提供修復方案。
