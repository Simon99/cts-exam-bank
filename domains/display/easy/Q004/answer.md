# DIS-E004 解答

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`  
**方法**: `BinderService.getDefaultBrightnessConfiguration()` (約第 4199-4208 行)

## 問題代碼

```java
@Override // Binder call
public BrightnessConfiguration getDefaultBrightnessConfiguration() {
    getDefaultBrightnessConfiguration_enforcePermission();
    final long token = Binder.clearCallingIdentity();
    try {
        synchronized (mSyncRoot) {
            return mDisplayPowerControllers.get(-1)  // ❌ BUG: 使用 -1 而不是 Display.DEFAULT_DISPLAY
                    .getDefaultBrightnessConfiguration();
        }
    } finally {
        Binder.restoreCallingIdentity(token);
    }
}
```

## 問題分析

### 錯誤原因

1. **使用了錯誤的 display ID**: 代碼使用 `-1` 作為 display ID，但 `Display.DEFAULT_DISPLAY` 的值是 `0`

2. **SparseArray 行為**: `mDisplayPowerControllers` 是一個 `SparseArray<DisplayPowerControllerInterface>`，當使用不存在的 key（-1）查詢時，返回 `null`

3. **缺少 null 檢查**: 代碼直接在返回值上調用方法，沒有檢查是否為 null

### 為什麼會產生這種 Bug

- 開發者可能誤以為 `-1` 代表「預設」或「第一個」顯示器
- 魔術數字 (magic number) 的使用沒有使用常量，容易出錯
- 缺少防禦性編程

## 修復方案

```java
@Override // Binder call
public BrightnessConfiguration getDefaultBrightnessConfiguration() {
    getDefaultBrightnessConfiguration_enforcePermission();
    final long token = Binder.clearCallingIdentity();
    try {
        synchronized (mSyncRoot) {
            return mDisplayPowerControllers.get(Display.DEFAULT_DISPLAY)  // ✅ 使用正確的常量
                    .getDefaultBrightnessConfiguration();
        }
    } finally {
        Binder.restoreCallingIdentity(token);
    }
}
```

## 修復 Patch

```diff
-                    return mDisplayPowerControllers.get(-1)
+                    return mDisplayPowerControllers.get(Display.DEFAULT_DISPLAY)
```

## 知識點

1. **Display ID 常量**: 
   - `Display.DEFAULT_DISPLAY = 0` （主要/內建顯示器）
   - 永遠使用常量而非魔術數字

2. **SparseArray**: Android 特有的資料結構，比 HashMap<Integer, V> 更省記憶體，但對不存在的 key 返回 null

3. **Binder 服務錯誤處理**: 服務端的異常會透過 Binder 傳遞給客戶端，可能暴露內部實現細節

## 延伸思考

- 即使修復了 display ID，如果 DisplayPowerController 尚未初始化，仍可能返回 null
- 更穩健的做法是加上 null 檢查並返回 null 或拋出更有意義的異常
