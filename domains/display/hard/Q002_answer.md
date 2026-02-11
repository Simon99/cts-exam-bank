# 答案：DIS-H002

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`

**方法**: `updateLocked()`（約第 456-462 行）

## 問題程式碼

```java
// Copy supported modes with state-aware optimization
int modeCount = deviceInfo.supportedModes.length;
if (mDirty && modeCount > 1) {
    // Optimization: skip redundant mode when display state changed
    modeCount = modeCount - 1;
}
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes, modeCount);
```

## Bug 分析

### 錯誤邏輯

這段程式碼引入了一個錯誤的「優化」邏輯：

1. **條件判斷**：當 `mDirty` 為 true 且模式數量大於 1 時
2. **錯誤操作**：將要複製的模式數量減 1
3. **結果**：`supportedModes` 陣列會少複製最後一個顯示模式

### 為什麼這是狀態機 Bug

這是一個典型的 **狀態相關計算錯誤**：

1. **`mDirty` 標誌的用途**：
   - 表示邏輯顯示的配置已被修改，需要重新同步
   - 由 `updateDisplayGroupIdLocked()`、`updateLayoutLimitedRefreshRateLocked()` 等方法設置

2. **觸發時機**：
   - 顯示群組 ID 變更時 `mDirty = true`
   - 刷新率限制變更時 `mDirty = true`
   - 熱節流配置變更時 `mDirty = true`

3. **Bug 特性**：
   - 只在髒狀態下觸發，非髒狀態下完全正常
   - 只影響多模式設備（`modeCount > 1`）
   - 總是丟失最後一個模式（通常是最高刷新率的模式）

### 為什麼難以發現

1. **間歇性**：不是每次查詢都會觸發，取決於 `mDirty` 狀態
2. **看似合理的註解**：「optimization」、「skip redundant」讓人誤以為是有意為之
3. **部分正確**：單模式設備完全不受影響
4. **狀態依賴**：問題與內部狀態機緊密耦合，單純看代碼邏輯不易發現

## 修復方案

移除錯誤的條件計算，直接複製完整的模式陣列：

```java
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes, deviceInfo.supportedModes.length);
```

## 完整 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java
+++ b/frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java
@@ -453,14 +453,8 @@ public final class LogicalDisplay {
             mBaseDisplayInfo.modeId = deviceInfo.modeId;
             mBaseDisplayInfo.renderFrameRate = deviceInfo.renderFrameRate;
             mBaseDisplayInfo.defaultModeId = deviceInfo.defaultModeId;
             mBaseDisplayInfo.userPreferredModeId = deviceInfo.userPreferredModeId;
-            // Copy supported modes with state-aware optimization
-            int modeCount = deviceInfo.supportedModes.length;
-            if (mDirty && modeCount > 1) {
-                // Optimization: skip redundant mode when display state changed
-                modeCount = modeCount - 1;
-            }
-            mBaseDisplayInfo.supportedModes = Arrays.copyOf(
-                    deviceInfo.supportedModes, modeCount);
+            mBaseDisplayInfo.supportedModes = Arrays.copyOf(
+                    deviceInfo.supportedModes, deviceInfo.supportedModes.length);
             mBaseDisplayInfo.colorMode = deviceInfo.colorMode;
             mBaseDisplayInfo.supportedColorModes = Arrays.copyOf(
                     deviceInfo.supportedColorModes,
```

## 學習要點

1. **狀態標誌的副作用**：`mDirty` 等狀態標誌應只用於控制更新流程，不應影響數據處理邏輯
2. **陣列複製**：`Arrays.copyOf()` 應該複製完整長度，除非有明確的截斷需求
3. **誤導性註解**：不要被「optimization」這類字眼迷惑，實際分析邏輯正確性
4. **邊界條件**：`modeCount > 1` 的條件表明設計者意識到邊界情況，但用錯了方向

## 驗證修復

修復後驗證：
1. 多模式設備在任何狀態下都能看到所有支援的模式
2. `Display.getSupportedModes().length` 應等於實際模式數量
3. 高刷新率模式（120Hz）不會間歇性消失

---
*難度：Hard | 實際耗時：___ 分鐘*
