# DIS-H001: VirtualDisplay 安全檢查邏輯漏洞

## 難度：Hard ⭐⭐⭐

## 失敗的 CTS 測試

```
android.hardware.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay
```

## 測試目的

此測試驗證 **untrusted virtual display 不能顯示 system decorations**。

System decorations（如狀態列、導航列）可能包含敏感資訊（通知內容、正在通話等）。如果惡意 app 可以建立一個帶有 system decorations 的 virtual display，它就能透過讀取 Surface 來竊取這些敏感資訊。

因此，只有 **trusted display**（持有 `ADD_TRUSTED_DISPLAY` 權限的系統程序建立）才能顯示 system decorations。

## 背景知識

### VirtualDisplay Flags 架構

```
VIRTUAL_DISPLAY_FLAG_TRUSTED (1 << 10)
    └── 只有系統程序可設置，表示這是可信任的 display

VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS (1 << 9)
    └── 表示此 display 應該顯示 system decorations

VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY (1 << 3)
    └── Display 只顯示自己的內容，不 mirror 預設 display
```

### 安全模型

```
┌─────────────────────────────────────────────────────────────┐
│                    VirtualDisplay 建立流程                    │
├─────────────────────────────────────────────────────────────┤
│  App 請求 flags                                              │
│       ↓                                                      │
│  DisplayManagerService.createVirtualDisplayInternal()       │
│       ↓                                                      │
│  安全檢查：untrusted display 必須清除敏感 flags              │
│       ↓                                                      │
│  建立 DisplayDevice                                          │
└─────────────────────────────────────────────────────────────┘
```

## 相關程式碼位置

```
frameworks/base/services/core/java/com/android/server/display/
└── DisplayManagerService.java
    └── createVirtualDisplayInternal() (約 1450-1750 行)
```

## 測試失敗訊息

```
junit.framework.AssertionFailedError: Untrusted virtual display should not have 
VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS flag set
Expected: flags without SHOULD_SHOW_SYSTEM_DECORATIONS
  Actual: flags = 0x608 (contains SHOULD_SHOW_SYSTEM_DECORATIONS)
```

## 提示

1. **理解安全邊界**：為什麼 untrusted display 不能顯示 system decorations？
2. **Flag 處理順序**：注意 flags 的處理順序和條件判斷邏輯
3. **誤導性優化**：有時候「看起來合理的優化」會打破安全模型
4. **跨模組思考**：`OWN_CONTENT_ONLY` 和 `SHOULD_SHOW_SYSTEM_DECORATIONS` 是獨立的安全屬性嗎？

## 你的任務

找出為什麼 untrusted virtual display 能夠保留 `VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS` flag。

---

**提交格式**：指出 bug 所在的程式碼位置，解釋 bug 的成因，並提供修復方案。
