# H-Q002: 答案

## Bug 位置

**檔案:** `frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java`

**問題:** 清理 short-term model 時用了全局清理，把其他用戶的配置也清掉了

## 調用鏈分析

```
DisplayManagerService.onSwitchUser()                    ← A: 打 log，用戶切換觸發
    ↓
DisplayPowerController.setBrightnessConfiguration()    ← B: 載入新用戶配置
    ↓
BrightnessMappingStrategy.clearShortTermModel()        ← C: 清理舊配置，BUG 在這
```

### A 層（DisplayManagerService）
```java
void onSwitchUser(int newUserId) {
    Slog.d(TAG, "Switching to user " + newUserId);
    mDisplayPowerController.onSwitchUser(newUserId);
}
```

### B 層（DisplayPowerController）
```java
void onSwitchUser(int newUserId) {
    BrightnessConfiguration config = loadConfigurationForUser(newUserId);
    mBrightnessMappingStrategy.setBrightnessConfiguration(config);
}
```

### C 層（BrightnessMappingStrategy）— BUG
```java
// 正確版本
public void setBrightnessConfiguration(BrightnessConfiguration config) {
    clearShortTermModel(mCurrentUserId);  // 只清理當前用戶的
    mConfiguration = config;
}

// Bug 版本
public void setBrightnessConfiguration(BrightnessConfiguration config) {
    clearShortTermModel();  // [BUG] 全局清理，清掉了所有用戶的配置
    mConfiguration = config;
}
```

### 邏輯分析

1. 用戶 A 設定了 configuration → 存在 per-user storage
2. 切換到用戶 B → clearShortTermModel() 被呼叫
3. **Bug：** clearShortTermModel() 清理了所有用戶的數據，包括用戶 A 的
4. 切回用戶 A → configuration 已經被清掉 → 返回 null

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java
+++ b/frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java
@@ -xxx,7 +xxx,7 @@ public class BrightnessMappingStrategy {
 
     public void setBrightnessConfiguration(BrightnessConfiguration config) {
-        clearShortTermModel();
+        clearShortTermModel(mCurrentUserId);
         mConfiguration = config;
     }
 }
```

## 診斷技巧

1. **從 DMS log 開始** - 確認用戶切換被觸發
2. **追蹤到 DisplayPowerController** - 確認配置載入邏輯
3. **追蹤到 BrightnessMappingStrategy** - 發現清理範圍問題
4. **對比 per-user vs global** - 清理應該是 per-user 的

## 評分標準

| 項目 | 分數 |
|------|------|
| 理解多用戶場景 | 15% |
| 追蹤到 DisplayPowerController | 20% |
| 追蹤到 BrightnessMappingStrategy | 30% |
| 識別出全局清理 vs per-user 清理 | 35% |
