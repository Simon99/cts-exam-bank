# Issue 0002: DIS-H002 — 修復中（等待驗證）

## 基本資訊
- **題目 ID**: DIS-H002 (display/hard/Q002)
- **原始問題**: Bug patch 導致系統崩潰（使用 mInfo.get() 作為觸發條件）
- **修復日期**: 2026-02-12

---

## 1. 問題根因

原始 bug 設計有缺陷：

```java
// 原始 bug patch（錯誤設計）
if (mInfo.get() != null && modeCount > 1) {
    modeCount = 1;  // 截斷 supportedModes
}
```

**問題**：
- `mInfo.get()` 在系統內部啟動流程中就會被設置
- 導致 `supportedModes` 在啟動時就被截斷
- 如果 active mode 是被截斷的 mode，系統崩潰

**錯誤發生位置**：`DisplayManagerService.getDisplayInfoForFrameRateOverride` 在系統啟動時呼叫

---

## 2. 修復方式

**方案：重新設計 bug，使用完全不同的觸發機制**

### 新設計：破壞 alternativeRefreshRates 的對稱性

```java
// BUG: Clear alternativeRefreshRates for non-default modes
mBaseDisplayInfo.supportedModes = new Display.Mode[deviceInfo.supportedModes.length];
for (int i = 0; i < deviceInfo.supportedModes.length; i++) {
    Display.Mode orig = deviceInfo.supportedModes[i];
    if (orig.getModeId() != deviceInfo.defaultModeId) {
        // Clear alternativeRefreshRates for non-default modes
        mBaseDisplayInfo.supportedModes[i] = new Display.Mode(
                orig.getModeId(), orig.getPhysicalWidth(), orig.getPhysicalHeight(),
                orig.getRefreshRate(), orig.getVsyncRate(),
                new float[0], orig.getSupportedHdrTypes());
    } else {
        mBaseDisplayInfo.supportedModes[i] = orig;
    }
}
```

### 新設計優點
1. **不會導致系統崩潰**：只是清空 alternativeRefreshRates，不截斷 modes
2. **CTS 可偵測**：`testGetSupportedModesOnDefaultDisplay` 會驗證 alternativeRefreshRates 的對稱性
3. **符合 Hard 難度**：需要理解圖論概念（對稱性）和 Display Mode 結構

### 更換的 CTS 測試
- **舊測試**：`testActiveModeIsSupportedModesOnDefaultDisplay`
- **新測試**：`testGetSupportedModesOnDefaultDisplay`

**原因**：原測試 (`testActiveModeIsSupportedModesOnDefaultDisplay`) 幾乎不可能因為 mode mismatch 而 FAIL，因為 `getMode()` 就是從 `supportedModes` 中取出的。

---

## 3. 驗證狀態

- ✅ Dry-run 通過
- ⏳ **等待真機驗證**

### 待執行的驗證步驟
1. 套用 patch 到 sandbox-2
2. 編譯 `services.jar`
3. Push 到設備並重啟
4. 確認系統正常啟動
5. 執行 CTS 測試 `testGetSupportedModesOnDefaultDisplay`
6. 確認測試 FAIL

---

## 4. 更新的檔案

- `domains/display/hard/Q002_bug.patch` — 新的 bug patch
- `domains/display/hard/Q002_question.md` — 更新題目描述
- `domains/display/hard/Q002_answer.md` — 更新答案
- `domains/display/hard/Q002_meta.json` — 更新 CTS 測試名稱

---

## 相關檔案
- Bug Patch: `domains/display/hard/Q002_bug.patch`
- Issue 原檔: `需要fix的問題/[InProgress]_Issue_0002_DIS_H002_system_crash.md`
