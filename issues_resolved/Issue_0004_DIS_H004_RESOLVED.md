# Issue 0004: DIS-H004 — 已解決

## 基本資訊
- **題目 ID**: DIS-H004 (display/hard/Q004)
- **原始問題**: Bug 會導致系統崩潰（截斷 supportedModes）
- **解決日期**: 2026-02-12

---

## 1. 問題根因

原始 bug 設計會在系統啟動時觸發：

```java
// 永遠截斷一個 mode
int effectiveCount = modesCount > 1
    ? Math.min(modesCount - 1, deviceInfo.supportedModes.length)
    : modesCount;
```

這會在 Display 子系統初始化時立即生效，導致崩潰。

---

## 2. 修復方式

**方案**：改為破壞 alternativeRefreshRates 的對稱性

```diff
-                    boolean isAlternative = j != i && other.width == mode.width
+                    // BUG: Only consider modes with higher index as alternatives
+                    // This breaks symmetry: if A lists B as alternative,
+                    // B should also list A, but this condition prevents it
+                    boolean isAlternative = j > i && other.width == mode.width
```

**設計邏輯**：
- `j != i` 改成 `j > i`
- 導致只有低 index 的 mode 會列出高 index 的 mode 作為 alternative
- 高 index 的 mode 不會列出低 index 的 mode
- CTS 測試會檢查對稱性並失敗

---

## 3. 驗證結果

✅ **測試正確偵測 bug**

- **測試名稱**: `android.display.cts.DisplayTest#testGetSupportedModesOnDefaultDisplay`
- **預期結果**: FAIL
- **實際結果**: FAIL (3.341s)

**錯誤訊息**：
```
Expected {id=1, fps=60.0, alternativeRefreshRates=[90.0]} 
to be listed as alternative refresh rate of 
{id=2, fps=90.0, alternativeRefreshRates=[]}
```

60Hz mode 列出 90Hz 作為 alternative，但 90Hz mode 的 alternatives 是空的。

---

## 相關檔案
- Bug Patch: `domains/display/hard/Q004_bug.patch`
- 題目: `domains/display/hard/Q004_question.md`
- 答案: `domains/display/hard/Q004_answer.md`
