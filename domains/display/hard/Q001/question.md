# DIS-H001: VirtualDisplay 安全檢查邏輯漏洞

## 難度：Hard ⭐⭐⭐

## 失敗的 CTS 測試

```
android.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay
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
│  如果 flag 未被清除 → 後續權限檢查 → 拋出 SecurityException  │
│       ↓                                                      │
│  建立 DisplayDevice                                          │
└─────────────────────────────────────────────────────────────┘
```

## 相關程式碼位置

```
frameworks/base/services/core/java/com/android/server/display/
└── DisplayManagerService.java
    └── createVirtualDisplayInternal() (約 1590-1650 行)
```

## 測試失敗訊息

```
java.lang.SecurityException: Requires INTERNAL_SYSTEM_WINDOW permission
    at com.android.server.display.DisplayManagerService.createVirtualDisplayInternal(DisplayManagerService.java:1623)
    at android.hardware.display.DisplayManager.createVirtualDisplay(DisplayManager.java:892)
    at android.display.cts.VirtualDisplayTest.testUntrustedSysDecorVirtualDisplay(VirtualDisplayTest.java:245)
```

## 提示

1. **理解安全邊界**：為什麼 untrusted display 不能顯示 system decorations？
2. **Flag 處理順序**：flag 在哪裡應該被清除？如果沒被清除會發生什麼？
3. **註解的陷阱**：被註解掉的程式碼可能隱藏著關鍵的安全邏輯
4. **防禦深度**：為什麼有兩層檢查（flag 清除 + 權限檢查）？

## 你的任務

找出為什麼 untrusted virtual display 會觸發 `SecurityException`，而不是正常建立（只是沒有 system decorations）。

---

**提交格式**：指出 bug 所在的程式碼位置，解釋 bug 的成因，並提供修復方案。
