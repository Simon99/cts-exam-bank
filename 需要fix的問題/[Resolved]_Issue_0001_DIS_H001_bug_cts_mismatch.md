# Issue 0001: DIS-H001 Bug Patch 與 CTS 測試不匹配

## 基本資訊
- **題目 ID**: DIS-H001 (display/hard/Q001)
- **發現日期**: 2026-02-11
- **嚴重程度**: High（題目無法正確驗證）

## 問題描述

Bug patch 套用後，CTS 測試**應該 FAIL**，但實際**仍然 PASS**。

## 根本原因

### Bug Patch 設計
```java
// 原始邏輯
if ((flags & TRUSTED) == 0) {
    flags &= ~SHOULD_SHOW_SYSTEM_DECORATIONS;  // 永遠清除
}

// Bug Patch（加了額外條件）
if ((flags & TRUSTED) == 0 && (flags & OWN_CONTENT_ONLY) == 0) {
    flags &= ~SHOULD_SHOW_SYSTEM_DECORATIONS;  // 條件限制清除
}
```

### CTS 測試實際行為
```java
createVirtualDisplay(..., SHOULD_SHOW_SYSTEM_DECORATIONS);  // 沒有傳 OWN_CONTENT_ONLY
```

### 問題分析
- CTS 測試沒有傳 `OWN_CONTENT_ONLY` flag
- 因此 `(flags & OWN_CONTENT_ONLY) == 0` 為 **true**
- Bug 條件仍然成立，flag 仍被清除
- 測試仍然通過，無法偵測到 bug

## 額外發現
- **測試類名錯誤**：題目中寫的類名有誤
- **正確類名**: `android.display.cts.VirtualDisplayTest`

## 建議修復方案

### 方案 A：修改 Bug Patch
設計一個不同的 bug，讓現有 CTS 測試能夠偵測到：
- 例如：直接移除 `TRUSTED` flag 檢查
- 或：反轉清除邏輯（不清除 → 清除）

### 方案 B：尋找匹配的 CTS 測試
找一個會傳 `OWN_CONTENT_ONLY | SHOULD_SHOW_SYSTEM_DECORATIONS` 的測試

### 方案 C：重新設計題目
基於這個 CTS 測試的實際行為，重新設計 bug 和問題

## 相關檔案
- Bug Patch: `~/develop_claw/cts-exam-bank/domains/display/hard/Q001/Q001_bug.patch`
- 題目: `~/develop_claw/cts-exam-bank/domains/display/hard/Q001/question.md`
- 修改檔案: `DisplayManagerService.java`

## 狀態
- [x] 已修復（2026-02-11）

## 修復方案（已驗證）
**方案：完全跳過 flag 清除邏輯**

```diff
--- a/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/services/core/java/com/android/server/display/DisplayManagerService.java
-        if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
-            flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
-        }
+        // BUG: Security check disabled - untrusted displays can now show system decorations
+        // Original code:
+        // if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
+        //     flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
+        // }
```

**驗證結果：**
- 測試名稱：`android.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay`
- 結果：FAIL（`SecurityException: Requires INTERNAL_SYSTEM_WINDOW permission`）
- 原因：flag 未被清除 → 觸發後續權限檢查 → 測試失敗
