# DIS-H002: 答案與解析

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`

**方法**：`updateDisplayInfoLocked()` (約第 470-485 行)

## Bug 程式碼

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

## 正確程式碼

```java
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes, deviceInfo.supportedModes.length);
```

## Bug 分析

### 錯誤的「優化」邏輯

開發者可能認為「非預設 mode 的 alternativeRefreshRates 資訊是多餘的」，因此清空它們以節省記憶體。

這導致了 alternativeRefreshRates 圖的不對稱：

### 問題示例（Pixel 7）

```
┌────────────────────────────────────────────────────────────┐
│ 原始資料（對稱）                                            │
├────────────────────────────────────────────────────────────┤
│ Mode 1 (60Hz): alternativeRefreshRates = [90.0]           │
│ Mode 2 (90Hz): alternativeRefreshRates = [60.0]           │
│                                                            │
│ 60Hz ←→ 90Hz（雙向可切換）                                 │
├────────────────────────────────────────────────────────────┤
│ Bug 後資料（不對稱）                                        │
├────────────────────────────────────────────────────────────┤
│ Mode 1 (60Hz): alternativeRefreshRates = [90.0]           │
│ Mode 2 (90Hz, default): alternativeRefreshRates = [60.0]  │
│                                                            │
│ 假設 defaultModeId = 2                                     │
│ → Mode 1 的 alternativeRefreshRates 被清空！              │
├────────────────────────────────────────────────────────────┤
│ 結果：                                                      │
│ Mode 1 (60Hz): alternativeRefreshRates = []               │
│ Mode 2 (90Hz): alternativeRefreshRates = [60.0]           │
│                                                            │
│ 90Hz → 60Hz ✓（Mode 2 說可以切換到 60Hz）                  │
│ 60Hz → 90Hz ✗（Mode 1 說沒有替代選項！）                   │
└────────────────────────────────────────────────────────────┘
```

### 為什麼這是問題？

1. **違反 API 契約**：Android 文件規定 alternativeRefreshRates 必須對稱

2. **CTS 驗證邏輯**：測試使用 Union-Find 演算法驗證對稱性
   - 遍歷每個 mode 的 alternativeRefreshRates
   - 檢查每個替代 rate 是否有對應的 mode
   - 檢查該 mode 是否也列出當前 mode 的 rate 作為替代

3. **用戶體驗不一致**：刷新率切換功能可能出現單向可用的情況

## 修復方案

移除條件式處理，直接複製所有 modes：

```diff
-            // BUG: Clear alternativeRefreshRates for non-default modes
-            mBaseDisplayInfo.supportedModes = new Display.Mode[deviceInfo.supportedModes.length];
-            for (int i = 0; i < deviceInfo.supportedModes.length; i++) {
-                Display.Mode orig = deviceInfo.supportedModes[i];
-                if (orig.getModeId() != deviceInfo.defaultModeId) {
-                    mBaseDisplayInfo.supportedModes[i] = new Display.Mode(
-                            orig.getModeId(), orig.getPhysicalWidth(), orig.getPhysicalHeight(),
-                            orig.getRefreshRate(), orig.getVsyncRate(),
-                            new float[0], orig.getSupportedHdrTypes());
-                } else {
-                    mBaseDisplayInfo.supportedModes[i] = orig;
-                }
-            }
+            mBaseDisplayInfo.supportedModes = Arrays.copyOf(
+                    deviceInfo.supportedModes, deviceInfo.supportedModes.length);
```

## 關鍵教訓

1. **對稱性是契約**：如果 API 設計有對稱性要求，必須嚴格遵守

2. **不要選擇性清除資料**：即使看起來「多餘」的資料，可能是其他功能依賴的

3. **理解 CTS 驗證邏輯**：CTS 測試會驗證這些 API 契約的正確性

4. **Display Mode 結構的完整性**：每個 Mode 的所有欄位都有存在的意義

## CTS 測試原理

`testGetSupportedModesOnDefaultDisplay` 的驗證邏輯：

```java
// 使用 Union-Find 演算法檢查對稱性
for (int i = 0; i < supportedModes.length; i++) {
    Display.Mode mode = supportedModes[i];
    for (float alternativeRate : mode.getAlternativeRefreshRates()) {
        // 1. 找到對應的替代 mode
        int matchingModeIdx = findModeByRefreshRate(supportedModes, alternativeRate);
        assertNotEquals(-1, matchingModeIdx);  // 必須存在
        
        // 2. 檢查對稱性：替代 mode 也必須列出當前 mode 的 rate
        // (透過 Union-Find 間接驗證)
    }
}
```

## 難度評估：Hard

- **資料結構理解**：需要理解 Display.Mode 的完整結構
- **圖論概念**：需要理解對稱性（無向圖）的概念
- **API 契約**：需要了解 Android 對 alternativeRefreshRates 的要求
- **條件邏輯分析**：需要分析何時觸發條件式處理
