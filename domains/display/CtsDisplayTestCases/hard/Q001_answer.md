# H-Q001: 答案

## Bug 位置

**檔案:** `frameworks/base/services/core/java/com/android/server/display/PersistentDataStore.java`

**問題:** 序列化 refreshRate 時把 float 強轉 int，丟失小數點精度

## 調用鏈分析

```
DisplayManagerService.setUserPreferredDisplayModeInternal()  ← A: 打 log，看起來成功
    ↓
DisplayDevice.setUserPreferredDisplayModeLocked()            ← B: 存到 device
    ↓
PersistentDataStore.setUserPreferredRefreshRate()            ← C: 序列化到 XML，BUG 在這
```

### A 層（DisplayManagerService）
```java
void setUserPreferredDisplayModeInternal(int displayId, Display.Mode mode) {
    Slog.d(TAG, "setUserPreferredDisplayMode: " + mode);  // log 顯示設定成功
    device.setUserPreferredDisplayModeLocked(mode);
    mPersistentDataStore.saveIfNeeded();
}
```

### B 層（DisplayDevice）
```java
void setUserPreferredDisplayModeLocked(Display.Mode mode) {
    mUserPreferredMode = mode;
    mPersistentDataStore.setUserPreferredResolution(mUniqueId, mode.getWidth(), mode.getHeight());
    mPersistentDataStore.setUserPreferredRefreshRate(mUniqueId, mode.getRefreshRate());
}
```

### C 層（PersistentDataStore）— BUG
```java
// 正確版本
public void setUserPreferredRefreshRate(String uniqueId, float refreshRate) {
    mUserPreferredRefreshRates.put(uniqueId, refreshRate);
    mDirty = true;
}

// Bug 版本
public void setUserPreferredRefreshRate(String uniqueId, float refreshRate) {
    mUserPreferredRefreshRates.put(uniqueId, (int) refreshRate);  // [BUG] float 轉 int
    mDirty = true;
}
```

### 邏輯分析

假設設定 refreshRate = 60.0Hz：
- 存入時：(int) 60.0 = 60
- 讀取時比較：60 != 60.0f → 判定為不匹配 → 返回 null

或者設定 refreshRate = 59.94Hz：
- 存入時：(int) 59.94 = 59
- 讀取時比較：59 != 59.94f → 判定為不匹配 → 返回 null

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/PersistentDataStore.java
+++ b/frameworks/base/services/core/java/com/android/server/display/PersistentDataStore.java
@@ -xxx,7 +xxx,7 @@ final class PersistentDataStore {
     public void setUserPreferredRefreshRate(String uniqueId, float refreshRate) {
-        mUserPreferredRefreshRates.put(uniqueId, (int) refreshRate);
+        mUserPreferredRefreshRates.put(uniqueId, refreshRate);
         mDirty = true;
     }
 }
```

## 診斷技巧

1. **從 DMS log 開始** - 確認 set 操作有被呼叫
2. **追蹤到 DisplayDevice** - 確認 mode 被傳遞
3. **追蹤到 PersistentDataStore** - 發現序列化問題
4. **檢查數據類型** - float 被轉成 int

## 評分標準

| 項目 | 分數 |
|------|------|
| 追蹤到 DisplayManagerService | 15% |
| 追蹤到 DisplayDevice | 20% |
| 追蹤到 PersistentDataStore | 30% |
| 識別出 float→int 精度丟失 | 35% |
