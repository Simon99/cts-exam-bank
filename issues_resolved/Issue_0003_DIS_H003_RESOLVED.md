# Issue 0003: DIS-H003 — 已解決

## 基本資訊
- **題目 ID**: DIS-H003 (display/hard/Q003)
- **原始問題**: Bug 未被 CTS 測試偵測（測試 PASS）
- **解決日期**: 2026-02-11

---

## 1. 問題根因

原始 bug 設計基於錯誤假設：

**原設計**：當 `baseModeId` 相同時跳過更新
```java
if (specs.baseModeId == mDesiredDisplayModeSpecs.baseModeId) {
    if (mPendingModeTransition) {
        return;  // 錯誤跳過
    }
}
```

**問題**：CTS 測試 `testModeSwitchOnPrimaryDisplay` 每次都切換到不同的 mode（不同的 baseModeId），所以條件不會觸發，bug 路徑無法被執行。

---

## 2. 修復方式

**方案**：改為拒絕所有非預設 mode 的切換請求

```diff
     public void setDesiredDisplayModeSpecsLocked(
             DisplayModeDirector.DesiredDisplayModeSpecs specs) {
+        // BUG: Reject mode changes that differ from default
+        if (specs != null && mBaseDisplayInfo != null) {
+            if (specs.baseModeId != mBaseDisplayInfo.defaultModeId) {
+                // Silently ignore non-default mode requests
+                return;
+            }
+        }
         mDesiredDisplayModeSpecs = specs;
     }
```

**設計邏輯**：
- CTS 測試會嘗試切換到各種 supported modes
- 當嘗試切換到非預設 mode 時，請求被靜默忽略
- Display 保持在預設 mode
- 測試等待 mode change 但永遠不會發生 → 觸發 timeout/assertion failure

---

## 3. 驗證結果

✅ **測試正確偵測 bug**

- **測試名稱**: `android.display.cts.DisplayTest#testModeSwitchOnPrimaryDisplay`
- **預期結果**: FAIL
- **實際結果**: FAIL (8.805s)
- **錯誤類型**: `java.lang.AssertionError` at `DisplayTest.java:789`

**錯誤位置**：`testSwitchToModeId()` 方法中的斷言失敗，表示 mode 切換未能成功。

---

## 相關檔案
- Bug Patch: `domains/display/hard/Q003_bug.patch`
- 題目: `domains/display/hard/Q003_question.md`
- 答案: `domains/display/hard/Q003_answer.md`
