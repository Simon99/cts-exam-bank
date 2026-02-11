# 解答：HDR 轉換模式設定邏輯錯誤

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`  
**方法**: `setHdrConversionModeInternal()`  
**行號**: 2439

## Bug 描述

條件判斷 `mOverrideHdrConversionMode == null` 被錯誤地寫成 `mOverrideHdrConversionMode != null`，導致覆蓋邏輯完全反轉。

### 錯誤代碼

```java
// If the HDR conversion is disabled by an app through WindowManager.LayoutParams, then
// set HDR conversion mode to HDR_CONVERSION_PASSTHROUGH.
if (mOverrideHdrConversionMode != null) {  // ❌ 錯誤：條件反轉
    // HDR_CONVERSION_FORCE with HDR_TYPE_INVALID is used to represent forcing SDR type.
    // But, internally SDR is selected by using passthrough mode.
    if (conversionMode == HdrConversionMode.HDR_CONVERSION_FORCE
            && preferredHdrType == Display.HdrCapabilities.HDR_TYPE_INVALID) {
        conversionMode = HdrConversionMode.HDR_CONVERSION_PASSTHROUGH;
    }
} else {
    conversionMode = mOverrideHdrConversionMode.getConversionMode();  // ❌ NPE!
    preferredHdrType = mOverrideHdrConversionMode.getPreferredHdrOutputType();
    autoHdrOutputTypes = null;
}
```

### 正確代碼

```java
// If the HDR conversion is disabled by an app through WindowManager.LayoutParams, then
// set HDR conversion mode to HDR_CONVERSION_PASSTHROUGH.
if (mOverrideHdrConversionMode == null) {  // ✅ 正確
    // HDR_CONVERSION_FORCE with HDR_TYPE_INVALID is used to represent forcing SDR type.
    // But, internally SDR is selected by using passthrough mode.
    if (conversionMode == HdrConversionMode.HDR_CONVERSION_FORCE
            && preferredHdrType == Display.HdrCapabilities.HDR_TYPE_INVALID) {
        conversionMode = HdrConversionMode.HDR_CONVERSION_PASSTHROUGH;
    }
} else {
    conversionMode = mOverrideHdrConversionMode.getConversionMode();
    preferredHdrType = mOverrideHdrConversionMode.getPreferredHdrOutputType();
    autoHdrOutputTypes = null;
}
```

## 問題分析

### 預期行為

1. **無覆蓋時** (`mOverrideHdrConversionMode == null`)：
   - 使用用戶設定的 `hdrConversionMode`
   - 若為 `HDR_CONVERSION_FORCE` 且目標為 SDR (`HDR_TYPE_INVALID`)，轉換為 `PASSTHROUGH` 模式

2. **有覆蓋時** (`mOverrideHdrConversionMode != null`)：
   - 忽略用戶設定
   - 使用應用程式指定的覆蓋模式

### 實際行為（Bug）

條件反轉導致：

1. **無覆蓋時** → 執行 else 分支 → 存取 null 的 `mOverrideHdrConversionMode` → **NullPointerException** 或錯誤行為

2. **有覆蓋時** → 執行 if 分支 → 使用用戶設定而非覆蓋設定 → **覆蓋功能失效**

### CTS 測試失敗原因

`HdrConversionEnabledTest#testSetHdrConversionMode` 測試驗證：
- 設定 `HDR_CONVERSION_FORCE` 模式後，系統應正確套用
- 當指定 `HDR_TYPE_INVALID` 時，應內部轉換為 `PASSTHROUGH`

Bug 導致無覆蓋情況下進入錯誤分支，無法正確處理 `HDR_CONVERSION_FORCE` + `HDR_TYPE_INVALID` 的轉換邏輯。

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -2436,7 +2436,7 @@ public final class DisplayManagerService extends SystemService {
             int conversionMode = hdrConversionMode.getConversionMode();
             int preferredHdrType = hdrConversionMode.getPreferredHdrOutputType();
             // If the HDR conversion is disabled by an app through WindowManager.LayoutParams, then
             // set HDR conversion mode to HDR_CONVERSION_PASSTHROUGH.
-            if (mOverrideHdrConversionMode != null) {
+            if (mOverrideHdrConversionMode == null) {
                 // HDR_CONVERSION_FORCE with HDR_TYPE_INVALID is used to represent forcing SDR type.
                 // But, internally SDR is selected by using passthrough mode.
                 if (conversionMode == HdrConversionMode.HDR_CONVERSION_FORCE
```

## 學習要點

1. **條件判斷要與分支邏輯一致**：仔細閱讀 if/else 兩個分支的實際操作，確保條件判斷正確

2. **Null 檢查的方向性**：
   - `== null` 表示「如果不存在則...」
   - `!= null` 表示「如果存在則...」

3. **註解與代碼一致性**：註解說明「If the HDR conversion is disabled by an app」應對應有覆蓋的情況，但 else 分支才是處理覆蓋的代碼

4. **覆蓋模式的設計模式**：先檢查是否有覆蓋，沒有覆蓋時才執行正常邏輯，這是常見的狀態管理模式

## 相關知識

- **HDR 轉換模式**：Android 支援多種 HDR 標準（HDR10、HDR10+、Dolby Vision、HLG），系統需要根據顯示器能力進行適當轉換
- **WindowManager 覆蓋機制**：應用可以請求特定的顯示設定，系統會暫時覆蓋用戶偏好
