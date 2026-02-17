# Issue 0001: DIS-H001 — 已解決

## 基本資訊
- **題目 ID**: DIS-H001 (display/hard/Q001)
- **原始問題**: Bug patch 與 CTS 測試不匹配
- **解決日期**: 2026-02-11

---

## 1. 問題根因

原始 bug patch 設計有缺陷：

```java
// 原始 bug patch（錯誤設計）
if ((flags & TRUSTED) == 0 && (flags & OWN_CONTENT_ONLY) == 0) {
    flags &= ~SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

**問題**：CTS 測試 `testUntrustedSysDecorVirtualDisplay` 沒有傳 `OWN_CONTENT_ONLY` flag，導致 bug 條件仍然成立，flag 被正常清除，測試 PASS。

**結果**：Bug 存在但測試無法偵測 → 題目無效。

---

## 2. 修復方式

**方案：完全跳過 flag 清除邏輯**

```diff
--- a/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -1649,9 +1649,12 @@ class DisplayManagerService extends SystemService {
         }

-        if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
-            flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
-        }
+        // BUG: Security check disabled - untrusted displays can now show system decorations
+        // Original code:
+        // if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
+        //     flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
+        // }
```

**修復流程**：
1. 修改 `Q001_bug.patch` 內容
2. Apply patch 到 `aosp-sandbox-1`
3. 重建 `services.jar`：`m services`（耗時約 3 分鐘）
4. Push 到設備：`adb push services.jar /system/framework/`
5. 重啟設備：`adb reboot`

---

## 3. 驗證結果

✅ **測試通過驗證**

- **測試名稱**: `android.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay`
- **預期結果**: FAIL
- **實際結果**: FAIL
- **失敗原因**: `SecurityException: Requires INTERNAL_SYSTEM_WINDOW permission`

**解釋**：
- Bug 讓 `SHOULD_SHOW_SYSTEM_DECORATIONS` flag 未被清除
- 後續程式碼檢查到未清除的 flag → 觸發權限檢查
- 測試沒有該權限 → 拋出 SecurityException → FAIL

---

## 相關檔案
- Bug Patch: `domains/display/hard/Q001/Q001_bug.patch`
- 題目: `domains/display/hard/Q001/question.md`
- 修改檔案: `DisplayManagerService.java`
