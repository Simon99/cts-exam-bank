# Q002 答案：Display Mode API 層數據丟失

## Bug 位置

**檔案**: `frameworks/base/core/java/android/view/Display.java`  
**方法**: `getSupportedModes()`  
**行號**: 約 1150 行

## Bug 描述

在 `Display.getSupportedModes()` 方法中，當複製 `supportedModes` 陣列返回給應用時，使用了錯誤的陣列長度：

```java
// 錯誤代碼
int copyLength = Math.max(1, modes.length - 1);
return Arrays.copyOf(modes, copyLength);

// 正確代碼
return Arrays.copyOf(modes, modes.length);
```

## 為什麼這會導致測試失敗

### 數據傳遞鏈

```
DisplayDeviceInfo.supportedModes (完整數據)
    ↓ LogicalDisplay.updateLocked() (正確複製)
DisplayInfo.supportedModes (完整數據 - 內部使用)
    ↓ Display.getSupportedModes() [BUG: 返回時截斷]
應用看到的 modes (丟失最後一個 mode)
```

### Bug 特點

這個 bug 特別隱蔽，因為：
1. **內部數據完整**：`DisplayInfo.supportedModes` 保持完整，系統內部運作正常
2. **只影響 API 層**：只有應用調用 `getSupportedModes()` 時才會看到截斷的數據
3. **系統穩定**：因為 `DisplayInfo.findMode()` 使用的是完整數據，系統不會崩潰

### 測試失敗原因

1. **testGetSupportedModesOnDefaultDisplay 失敗**:
   - 90Hz mode 的 `alternativeRefreshRates` 包含 `[60.0]`
   - 但 `getSupportedModes()` 返回的陣列中可能缺少 60Hz 或 90Hz mode
   - 測試檢查：每個 alternativeRefreshRate 必須有對應的 supportedMode
   - 失敗訊息: "Could not find alternative display mode with refresh rate..."

2. **testActiveModeIsSupportedModesOnDefaultDisplay 失敗**:
   - 如果當前 active mode 恰好是被截斷的那個
   - `getMode()` 返回的 mode 不在 `getSupportedModes()` 返回的陣列中
   - 測試失敗

## 涉及的 3 個檔案

| 檔案 | 角色 | 說明 |
|-----|------|-----|
| `DisplayDeviceInfo.java` | 源數據 | 定義 `supportedModes` 陣列，包含完整的 modes |
| `DisplayInfo.java` | 內部數據 | 持有完整的 `supportedModes`，內部功能正常 |
| `Display.java` | API 層 | **BUG 位置** - 返回給應用時截斷陣列 |

## 修復方法

```diff
 public Mode[] getSupportedModes() {
     synchronized (mLock) {
         updateDisplayInfoLocked();
         final Display.Mode[] modes = mDisplayInfo.supportedModes;
-        int copyLength = Math.max(1, modes.length - 1);
-        return Arrays.copyOf(modes, copyLength);
+        return Arrays.copyOf(modes, modes.length);
     }
 }
```

## 學習重點

1. **API 層 vs 內部層**：Bug 可能只影響對外 API，而內部運作正常，這類 bug 更難發現
2. **Off-by-one 的位置**：同樣的邏輯錯誤放在不同位置，影響完全不同
3. **防禦性複製的陷阱**：`Arrays.copyOf()` 用於防禦性複製時，長度參數錯誤會導致數據丟失
4. **數據一致性**：`getMode()` 和 `getSupportedModes()` 返回的數據必須保持一致
