# H-Q004: 答案

## Bug 位置

**檔案:** `frameworks/base/services/core/java/com/android/server/display/LocalDisplayAdapter.java`

**問題:** 把 `COLOR_MODE_WIDE_COLOR_GAMUT` 映射到了錯誤的 HAL 常數

## 調用鏈分析

```
DisplayManagerService.configureColorModeLocked()         ← A: 收到設定請求，打 log
    ↓
LogicalDisplay.setRequestedColorModeLocked()             ← B: 更新 requested color mode
    ↓
LocalDisplayAdapter.requestColorMode()                    ← C: 映射到 HAL，BUG 在這
```

### A 層（DisplayManagerService）
```java
void configureColorModeLocked(int displayId, int colorMode) {
    Slog.d(TAG, "Configuring color mode: " + colorMode);
    LogicalDisplay display = mLogicalDisplays.get(displayId);
    display.setRequestedColorModeLocked(colorMode);
}
```

### B 層（LogicalDisplay）
```java
void setRequestedColorModeLocked(int colorMode) {
    mRequestedColorMode = colorMode;
    mDisplayDevice.requestColorMode(colorMode);
}
```

### C 層（LocalDisplayAdapter）— BUG
```java
// 正確版本
void requestColorMode(int colorMode) {
    int halColorMode;
    switch (colorMode) {
        case Display.COLOR_MODE_WIDE_COLOR_GAMUT:
            halColorMode = HAL_COLOR_MODE_WIDE;
            break;
        case Display.COLOR_MODE_DEFAULT:
        default:
            halColorMode = HAL_COLOR_MODE_DEFAULT;
            break;
    }
    nativeSetColorMode(halColorMode);
}

// Bug 版本
void requestColorMode(int colorMode) {
    int halColorMode;
    switch (colorMode) {
        case Display.COLOR_MODE_WIDE_COLOR_GAMUT:
            halColorMode = HAL_COLOR_MODE_DEFAULT;  // [BUG] 映射到錯誤的 HAL 常數
            break;
        case Display.COLOR_MODE_DEFAULT:
        default:
            halColorMode = HAL_COLOR_MODE_DEFAULT;
            break;
    }
    nativeSetColorMode(halColorMode);
}
```

### 邏輯分析

當設定 `COLOR_MODE_WIDE_COLOR_GAMUT` 時：
- 上層 API 顯示已啟用 wide color（`isWideColorGamut()` 返回 true）
- 但底層 HAL 被設成了 `HAL_COLOR_MODE_DEFAULT`
- 實際硬體沒有啟用 wide color mode
- `getSupportedWideColorGamuts()` 查詢實際硬體狀態，返回空陣列

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/LocalDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/LocalDisplayAdapter.java
@@ -xxx,7 +xxx,7 @@ class LocalDisplayAdapter {
     void requestColorMode(int colorMode) {
         int halColorMode;
         switch (colorMode) {
             case Display.COLOR_MODE_WIDE_COLOR_GAMUT:
-                halColorMode = HAL_COLOR_MODE_DEFAULT;
+                halColorMode = HAL_COLOR_MODE_WIDE;
                 break;
             // ...
         }
     }
 }
```

## 診斷技巧

1. **分析矛盾現象** - isWideColorGamut() 和 getSupportedWideColorGamuts() 結果矛盾
2. **追蹤設定路徑** - DMS → LogicalDisplay → LocalDisplayAdapter
3. **檢查 HAL 映射** - 發現 WIDE 被錯誤映射到 DEFAULT
4. **理解上層 vs 底層** - 上層記錄 vs 實際硬體狀態

## 評分標準

| 項目 | 分數 |
|------|------|
| 理解矛盾現象的原因 | 15% |
| 追蹤到 LocalDisplayAdapter | 25% |
| 找到 requestColorMode 方法 | 25% |
| 識別出 HAL 常數映射錯誤 | 35% |
