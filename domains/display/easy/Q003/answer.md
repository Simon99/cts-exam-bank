# 解答：DIS-E003

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**方法**：`getDefaultBrightnessConfiguration()` (第 4201-4211 行)

## Bug 原因

程式碼錯誤地使用了 `Display.INVALID_DISPLAY`（值為 -1）作為鍵值來查詢 `mDisplayPowerControllers`，而不是正確的 `Display.DEFAULT_DISPLAY`（值為 0）。

### 錯誤程式碼
```java
@Override // Binder call
public BrightnessConfiguration getDefaultBrightnessConfiguration() {
    getDefaultBrightnessConfiguration_enforcePermission();
    final long token = Binder.clearCallingIdentity();
    try {
        synchronized (mSyncRoot) {
            return mDisplayPowerControllers.get(Display.INVALID_DISPLAY)  // ❌ 錯誤！
                    .getDefaultBrightnessConfiguration();
        }
    } finally {
        Binder.restoreCallingIdentity(token);
    }
}
```

## 為什麼會失敗

1. `mDisplayPowerControllers` 是一個 `SparseArray<DisplayPowerControllerInterface>`，用 display ID 作為鍵
2. 系統只會為有效的顯示器建立 `DisplayPowerController`
3. `Display.INVALID_DISPLAY` (-1) 不是有效的 display ID，所以 `get(-1)` 返回 `null`
4. 對 `null` 物件呼叫 `getDefaultBrightnessConfiguration()` 導致 NullPointerException

## 修復方案

將 `Display.INVALID_DISPLAY` 改為 `Display.DEFAULT_DISPLAY`：

```java
@Override // Binder call
public BrightnessConfiguration getDefaultBrightnessConfiguration() {
    getDefaultBrightnessConfiguration_enforcePermission();
    final long token = Binder.clearCallingIdentity();
    try {
        synchronized (mSyncRoot) {
            return mDisplayPowerControllers.get(Display.DEFAULT_DISPLAY)  // ✅ 正確
                    .getDefaultBrightnessConfiguration();
        }
    } finally {
        Binder.restoreCallingIdentity(token);
    }
}
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -4203,7 +4203,7 @@ public final class DisplayManagerService extends SystemService {
             final long token = Binder.clearCallingIdentity();
             try {
                 synchronized (mSyncRoot) {
-                    return mDisplayPowerControllers.get(Display.INVALID_DISPLAY)
+                    return mDisplayPowerControllers.get(Display.DEFAULT_DISPLAY)
                             .getDefaultBrightnessConfiguration();
                 }
             } finally {
```

## 學習重點

1. **常數誤用**：`Display.INVALID_DISPLAY` 和 `Display.DEFAULT_DISPLAY` 名稱相似，容易混淆
2. **空值檢查**：即使修復後，生產環境中仍應考慮加入 null 檢查以增加防禦性
3. **SparseArray 行為**：`SparseArray.get()` 在鍵不存在時返回 null，不會拋出異常

## Bug 類型

- **COND**：條件判斷錯誤（使用錯誤的常數）
- **STATE**：狀態查詢錯誤（查詢不存在的 display ID）
