# Q010: 答案解析

## 問題根源

`ActivityRecord.java` 的 `sendResult()` 方法在傳遞 Activity 結果時，錯誤地添加了 `getTopResumedActivity() == this` 的檢查，導致在 multi-resume 模式（分屏）下非 top resumed 的 Activity 無法立即收到結果。

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/wm/ActivityRecord.java`

```java
void sendResult(int callingUid, String resultWho, int requestCode, int resultCode,
        Intent data, IBinder callerToken, NeededUriGrants dataGrants,
        boolean forceSendForMediaProjection) {
    
    // BUG: 額外的 topResumedActivity 檢查
    // 在分屏模式下，只有一個 Activity 是 topResumed，但兩個都是 RESUMED
    if (isState(RESUMED) && attachedToProcess() 
            && mRootWindowContainer.getTopResumedActivity() == this) {  // 錯誤！
        // 立即傳遞結果
        try {
            final ArrayList<ResultInfo> list = new ArrayList<>();
            list.add(new ResultInfo(resultWho, requestCode, resultCode, data, callerToken));
            mAtmService.getLifecycleManager().scheduleTransactionItem(app.getThread(),
                    ActivityResultItem.obtain(token, list));
            return;
        } catch (Exception e) {
            // ...
        }
    }
    
    // 結果被加入 pending list，等待 Activity resume
    addResultLocked(null, resultWho, requestCode, resultCode, data, callerToken);
}
```

## 診斷步驟

1. **添加 log 追蹤結果傳遞**:
```java
// ActivityRecord.java sendResult()
Log.d("ActivityRecord", "sendResult: activity=" + shortComponentName
    + " state=" + mState 
    + " isTopResumed=" + (mRootWindowContainer.getTopResumedActivity() == this)
    + " attachedToProcess=" + attachedToProcess());
```

2. **觀察 log（分屏模式下）**:
```
# 左邊的 ActivityA 是 RESUMED 但不是 topResumed
D ActivityRecord: sendResult: activity=ActivityA state=RESUMED isTopResumed=false attached=true
# 結果被 pending 而不是立即傳遞！

# 右邊的 ActivityB 是 topResumed
D ActivityRecord: sendResult: activity=ActivityB state=RESUMED isTopResumed=true attached=true
# 這個會立即傳遞
```

3. **問題定位**: 
   - Multi-resume 模式下多個 Activity 可以同時處於 RESUMED 狀態
   - 只有一個是 topResumed（最近互動的那個）
   - Bug 錯誤地將「可以接收結果」與「是 topResumed」綁定

## 問題分析

Multi-resume 模式（Android 10+）的行為：
1. 分屏/自由形式窗口下，多個 Activity 可以同時 RESUMED
2. `topResumedActivity` 只是標識「最近互動的」Activity
3. 所有 RESUMED 的 Activity 都應該能接收結果

正確的邏輯：
- Activity 只要是 RESUMED 且 attached，就應該立即接收結果
- topResumed 狀態與結果傳遞無關

Bug 的影響：
- 分屏模式下，非 topResumed 的 Activity 無法立即收到 `onActivityResult()`
- 用戶在一側窗口操作後，另一側窗口的結果被延遲

## 正確代碼

```java
void sendResult(int callingUid, String resultWho, int requestCode, int resultCode,
        Intent data, IBinder callerToken, NeededUriGrants dataGrants,
        boolean forceSendForMediaProjection) {
    
    // 正確：只檢查 RESUMED 狀態，不檢查 topResumed
    if (isState(RESUMED) && attachedToProcess()) {
        try {
            final ArrayList<ResultInfo> list = new ArrayList<>();
            list.add(new ResultInfo(resultWho, requestCode, resultCode, data, callerToken));
            mAtmService.getLifecycleManager().scheduleTransactionItem(app.getThread(),
                    ActivityResultItem.obtain(token, list));
            return;
        } catch (Exception e) {
            Slog.w(TAG, "Exception thrown sending result to " + this, e);
        }
    }
    
    addResultLocked(null, resultWho, requestCode, resultCode, data, callerToken);
}
```

## 修復驗證

```bash
atest android.app.cts.ActivityResultTest#testResultDeliveryMultiResume
atest com.android.server.wm.ActivityRecordTests#testSendResultMultiResume
```

## 難度分類理由

**Hard** - 需要理解 Android 的 multi-resume 模式、Activity 生命週期狀態（RESUMED vs topResumed）、以及 Activity result 傳遞機制。Bug 只在特定場景（分屏模式）下觸發，涉及 ActivityRecord、RootWindowContainer 等多個組件。
