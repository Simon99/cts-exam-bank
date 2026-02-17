# DIS-H003: 答案與解析

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`

**方法**：`setDesiredDisplayModeSpecsLocked()` (約第 738-750 行)

## Bug 程式碼

```java
public void setDesiredDisplayModeSpecsLocked(
        DisplayModeDirector.DesiredDisplayModeSpecs specs) {
    // BUG: Reject mode changes that differ from default
    if (specs != null && mBaseDisplayInfo != null) {
        if (specs.baseModeId != mBaseDisplayInfo.defaultModeId) {
            // Silently ignore non-default mode requests
            return;
        }
    }
    mDesiredDisplayModeSpecs = specs;
}
```

## 正確程式碼

```java
public void setDesiredDisplayModeSpecsLocked(
        DisplayModeDirector.DesiredDisplayModeSpecs specs) {
    mDesiredDisplayModeSpecs = specs;
}
```

## Bug 分析

### 錯誤的「保護」邏輯

開發者加入了一個看似合理的「保護」：

> 「只接受切換到預設 mode 的請求，拒絕其他 mode。」

這完全破壞了 mode switching 功能：

### 問題行為

```
┌────────────────────────────────────────────────────────────┐
│ 情境：設備有 60Hz（預設）和 90Hz 兩個 mode                   │
├────────────────────────────────────────────────────────────┤
│ 1. App 請求切換到 90Hz                                      │
│    specs.baseModeId = 2 (90Hz)                             │
│    defaultModeId = 1 (60Hz)                                │
│                                                            │
│ 2. Bug 條件觸發                                            │
│    specs.baseModeId (2) != defaultModeId (1)              │
│    → return，不設置 mDesiredDisplayModeSpecs               │
│                                                            │
│ 3. 結果                                                    │
│    請求被靜默忽略                                          │
│    Display 保持在 60Hz                                      │
│    App 永遠等不到 mode change 通知                          │
└────────────────────────────────────────────────────────────┘
```

### 為什麼這是嚴重問題？

1. **破壞核心功能**：Mode switching 是 Android display 系統的基本能力

2. **靜默失敗**：沒有錯誤訊息，難以診斷

3. **影響使用者體驗**：
   - 遊戲無法使用高刷新率
   - 影片播放無法匹配內容 frame rate
   - 省電模式無法降低刷新率

4. **App 相容性**：依賴 mode switching 的 app 會 hang 在等待狀態

### 錯誤的假設

開發者可能認為：
> 「只允許預設 mode 可以提高穩定性或省電」

但這個假設是錯誤的：
- Android 明確支援動態 mode switching
- 這個決策應該由更高層（DisplayModeDirector）做，不是在這裡

## 修復方案

移除錯誤的條件檢查：

```diff
     public void setDesiredDisplayModeSpecsLocked(
             DisplayModeDirector.DesiredDisplayModeSpecs specs) {
-        // BUG: Reject mode changes that differ from default
-        if (specs != null && mBaseDisplayInfo != null) {
-            if (specs.baseModeId != mBaseDisplayInfo.defaultModeId) {
-                // Silently ignore non-default mode requests
-                return;
-            }
-        }
         mDesiredDisplayModeSpecs = specs;
     }
```

## 關鍵教訓

1. **不要靜默忽略請求**：如果要拒絕，至少要 log 或拋出異常

2. **理解系統架構**：Mode 決策應該在 DisplayModeDirector，不是 LogicalDisplay

3. **default != only allowed**：預設值不代表是唯一允許的值

4. **測試各種 mode**：不要只測試預設 mode

## CTS 測試原理

`testModeSwitchOnPrimaryDisplay` 的測試邏輯：

```java
@Test
public void testModeSwitchOnPrimaryDisplay() throws Exception {
    Display.Mode[] modes = mDefaultDisplay.getSupportedModes();
    assumeTrue("Need two or more modes", modes.length > 1);
    
    for (Display.Mode mode : modes) {
        // 請求切換到每個 supported mode
        activity.setPreferredDisplayMode(mode);
        
        // 等待 mode change 完成（最多 5 秒）
        assertTrue(changeSignal.await(5, TimeUnit.SECONDS));  // 這裡 timeout！
        
        // 驗證切換成功
        assertEquals(mode.getRefreshRate(), currentMode.mRefreshRate, TOLERANCE);
    }
}
```

## 難度評估：Hard

- **靜默失敗**：沒有明顯的錯誤訊息，只有 timeout
- **系統層問題**：需要理解 display mode 的完整資料流
- **看似合理的限制**：條件判斷看起來像是某種「保護」機制
- **時序依賴**：只有在切換到非預設 mode 時才會失敗
