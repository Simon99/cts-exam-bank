# Q003: 答案解析

## 問題根源

本題有三個 Bug，分布在廣播處理鏈的不同階段：

### Bug 1: BroadcastQueueImpl.java
`finishReceiverLocked()` 只在所有接收器處理完後才更新結果，導致中間結果丟失。

### Bug 2: BroadcastRecord.java
結果字段在某些情況下被錯誤重置。

### Bug 3: LoadedApk.java (ReceiverDispatcher)
結果回傳時使用了錯誤的參數順序或丟失了數據。

## Bug 1 位置

`frameworks/base/services/core/java/com/android/server/am/BroadcastQueueImpl.java`

```java
void finishReceiverLocked(BroadcastRecord r, int resultCode,
        String resultData, Bundle resultExtras, boolean resultAbort) {
    // ...
    
    // BUG: 只在最後一個接收器時才更新結果
    if (r.nextReceiver >= r.receivers.size()) {
        r.resultCode = resultCode;
        r.resultData = resultData;
        r.resultExtras = resultExtras;
    } else if (resultAbort && (r.intent.getFlags()&Intent.FLAG_RECEIVER_NO_ABORT) == 0) {
        r.resultAbort = resultAbort;
    }
    // 應該每次都更新結果字段
}
```

## Bug 2 位置

`frameworks/base/services/core/java/com/android/server/am/BroadcastRecord.java`

```java
void resetDeliveryState() {
    // BUG: 重置時清除了已設置的結果
    resultCode = Activity.RESULT_CANCELED;
    resultData = null;
    resultExtras = null;
    // 這個方法不應該清除結果字段
}
```

## Bug 3 位置

`frameworks/base/core/java/android/app/LoadedApk.java`

```java
public final class ReceiverDispatcher {
    final class Args extends BroadcastReceiver.PendingResult implements Runnable {
        public void run() {
            // ...
            try {
                receiver.onReceive(mContext, intent);
            } catch (Exception e) {
                // ...
            }
            
            // BUG: finish 時參數順序錯誤
            finish(mResultCode, mResultData, mResultExtras, false, mFlags);
            // 應該傳入接收器設置的新值，而不是舊值
        }
    }
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 BroadcastQueueImpl.finishReceiverLocked 中
Log.d("BroadcastQueue", "finishReceiver: nextReceiver=" + r.nextReceiver + 
      ", total=" + r.receivers.size() + ", resultCode=" + resultCode);

// 在 BroadcastRecord.resetDeliveryState 中
Log.d("BroadcastRecord", "resetDeliveryState called, clearing results");

// 在 LoadedApk.ReceiverDispatcher.Args.run 中
Log.d("ReceiverDispatcher", "finish: resultCode=" + mResultCode);
```

2. **觀察 log**:
```
D ReceiverDispatcher: receiver 1 setResultCode(100)
D BroadcastQueue: finishReceiver: nextReceiver=1, total=2, resultCode=100
D BroadcastRecord: resetDeliveryState called  # 結果被清除！
D BroadcastQueue: finishReceiver: nextReceiver=2, total=2, resultCode=-1
```

3. **定位問題**: 結果只在最後才存儲，且中間可能被重置

## 問題分析

### Bug 1 分析
finishReceiverLocked 應該每次都更新 BroadcastRecord 的結果字段，讓下一個接收器能看到前一個的修改。

### Bug 2 分析
resetDeliveryState 不應該清除結果字段，只應該重置投遞狀態。

### Bug 3 分析
ReceiverDispatcher 在 finish 時應該使用接收器修改後的結果值。

## 正確代碼

### 修復 Bug 1 (BroadcastQueueImpl.java)
```java
void finishReceiverLocked(BroadcastRecord r, int resultCode,
        String resultData, Bundle resultExtras, boolean resultAbort) {
    // 每次都更新結果
    r.resultCode = resultCode;
    r.resultData = resultData;
    r.resultExtras = resultExtras;
    if (resultAbort && (r.intent.getFlags()&Intent.FLAG_RECEIVER_NO_ABORT) == 0) {
        r.resultAbort = resultAbort;
    }
}
```

### 修復 Bug 2 (BroadcastRecord.java)
```java
void resetDeliveryState() {
    // 不清除結果字段
    // resultCode = Activity.RESULT_CANCELED;  // 移除
    // resultData = null;                       // 移除
    // resultExtras = null;                     // 移除
    // 只重置投遞相關狀態
    nextReceiver = 0;
    // ...
}
```

### 修復 Bug 3 (LoadedApk.java)
```java
public void run() {
    // ...
    receiver.onReceive(mContext, intent);
    
    // 使用接收器修改後的值
    finish(getResultCode(), getResultData(), getResultExtras(false), 
           false, mFlags);
}
```

## 修復驗證

```bash
atest android.content.cts.BroadcastReceiverTest#testOrderedBroadcastResult
```

## 難度分類理由

**Hard** - 需要深入理解有序廣播的完整處理流程，追蹤跨三個文件（系統服務層、框架層）的結果傳遞邏輯，涉及複雜的狀態管理。
