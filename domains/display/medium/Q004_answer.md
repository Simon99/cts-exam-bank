# 答案：Per-Display Brightness Configuration Bug

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`  
**方法**：`setBrightnessConfigurationForDisplayInternal()`  
**行號**：約 2525 行

## 問題程式碼

```java
private void setBrightnessConfigurationForDisplayInternal(
        @Nullable BrightnessConfiguration c, String uniqueId, @UserIdInt int userId,
        String packageName) {
    validateBrightnessConfiguration(c);
    final int userSerial = getUserManager().getUserSerialNumber(userId);
    synchronized (mSyncRoot) {
        try {
            DisplayDevice displayDevice = mDisplayDeviceRepo.getByUniqueIdLocked(uniqueId);
            if (displayDevice != null) {  // ← BUG：條件反了！
                return;
            }
            // ... 後續的儲存邏輯永遠不會執行
```

## 根本原因

**條件判斷邏輯反轉**：原本應該在找不到設備時返回（`displayDevice == null`），但被錯誤地寫成找到設備時返回（`displayDevice != null`）。

這導致：
1. 當 `uniqueId` 對應的設備存在時，函數立即返回，不做任何事
2. 後續的 `setBrightnessConfigurationForDisplayLocked()` 永遠不會被呼叫
3. 亮度配置永遠無法儲存到 `PersistentDataStore`
4. `getBrightnessConfigurationForDisplay()` 自然取不到剛設定的值

## 修復方案

```java
// 修復：恢復正確的 null 檢查
DisplayDevice displayDevice = mDisplayDeviceRepo.getByUniqueIdLocked(uniqueId);
if (displayDevice == null) {  // ← 找不到設備才應該 return
    return;
}
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -2523,7 +2523,7 @@ public final class DisplayManagerService extends SystemService {
         synchronized (mSyncRoot) {
             try {
                 DisplayDevice displayDevice = mDisplayDeviceRepo.getByUniqueIdLocked(uniqueId);
-                if (displayDevice != null) {
+                if (displayDevice == null) {
                     return;
                 }
                 if (mLogicalDisplayMapper.getDisplayLocked(displayDevice) != null
```

## 影響分析

### 直接影響
- **Per-display brightness** 功能完全失效
- 多螢幕設備無法為各別螢幕設定不同亮度曲線
- 使用者自訂亮度偏好無法儲存

### CTS 測試失敗原因
測試流程：
1. 設定亮度配置 → 函數提前返回，未儲存
2. 讀取亮度配置 → 從 PersistentDataStore 取不到
3. 比較結果 → 預期值 vs null/default，斷言失敗

## 學習要點

1. **Null check 方向**：這是最常見的防禦性程式設計錯誤之一
2. **Early return pattern**：正確使用 guard clause 應該是 "invalid case → return"
3. **條件語意**：寫 `if (x != null)` 時要確認語意是「有效值」還是「無效值」

## 類似案例

這種 null check 反轉的 bug 在 AOSP 中偶爾出現：
- 權限檢查（有權限 vs 無權限）
- 資源查找（找到 vs 找不到）
- 狀態驗證（有效 vs 無效）

建議閱讀程式碼時多問：「在什麼情況下我們應該 **不** 繼續執行？」
