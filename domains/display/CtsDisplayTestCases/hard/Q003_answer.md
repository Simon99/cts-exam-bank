# H-Q003: 答案

## Bug 位置

**檔案:** `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**問題:** `notifyDisplayEventAsync()` 中的 diff bitmask 檢查遺漏了 `DIFF_OTHER`

## 調用鏈分析

```
DisplayManagerService.handleDisplayDeviceChanged()        ← A: 偵測到變化，打 log
    ↓
LogicalDisplayMapper.updateLogicalDisplays()             ← B: 處理映射更新
    ↓
DisplayManagerService.CallbackRecord.notifyDisplayEventAsync()  ← C: 派發通知，BUG 在這
```

### A 層（DisplayManagerService）
```java
void handleDisplayDeviceChanged(DisplayDevice device) {
    Slog.d(TAG, "Display device changed: " + device);
    mLogicalDisplayMapper.updateLogicalDisplays();
    notifyDisplayChanged(device.getDisplayId());
}
```

### B 層（LogicalDisplayMapper）
```java
void updateLogicalDisplays() {
    // 計算 display info 的 diff
    int diff = computeDiff(oldInfo, newInfo);
    if (diff != 0) {
        notifyListeners(diff);
    }
}
```

### C 層（DisplayManagerService.CallbackRecord）— BUG
```java
// 正確版本
void notifyDisplayEventAsync(int displayId, int event, int diff) {
    if ((diff & (DIFF_STATE | DIFF_COLOR_MODE | DIFF_OTHER)) != 0) {
        mHandler.post(() -> mCallback.onDisplayChanged(displayId));
    }
}

// Bug 版本
void notifyDisplayEventAsync(int displayId, int event, int diff) {
    if ((diff & (DIFF_STATE | DIFF_COLOR_MODE)) != 0) {  // [BUG] 遺漏 DIFF_OTHER
        mHandler.post(() -> mCallback.onDisplayChanged(displayId));
    }
}
```

### 邏輯分析

Display 變化的 diff 類型：
- `DIFF_STATE` - 開關狀態變化
- `DIFF_COLOR_MODE` - 色彩模式變化
- `DIFF_OTHER` - 其他變化（如 refresh rate、mode 等）

**正確邏輯：** 三種 diff 都應該觸發回調

**Bug 邏輯：** 只檢查了 `DIFF_STATE | DIFF_COLOR_MODE`，遺漏了 `DIFF_OTHER`

當 display 變化類型是 `DIFF_OTHER` 時，回調不會被觸發。

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -xxx,7 +xxx,7 @@ public final class DisplayManagerService {
 
     private final class CallbackRecord {
         void notifyDisplayEventAsync(int displayId, int event, int diff) {
-            if ((diff & (DIFF_STATE | DIFF_COLOR_MODE)) != 0) {
+            if ((diff & (DIFF_STATE | DIFF_COLOR_MODE | DIFF_OTHER)) != 0) {
                 mHandler.post(() -> mCallback.onDisplayChanged(displayId));
             }
         }
     }
 }
```

## 診斷技巧

1. **從 DMS log 開始** - 確認 display 變化被偵測
2. **追蹤到 LogicalDisplayMapper** - 確認 diff 被計算
3. **追蹤到 notifyDisplayEventAsync** - 發現 bitmask 過濾問題
4. **檢查 DIFF_* 常數** - 確認遺漏了 DIFF_OTHER

## 評分標準

| 項目 | 分數 |
|------|------|
| 理解事件產生 vs 派發 | 15% |
| 追蹤到 LogicalDisplayMapper | 20% |
| 追蹤到 notifyDisplayEventAsync | 30% |
| 識別出 bitmask 遺漏 DIFF_OTHER | 35% |
