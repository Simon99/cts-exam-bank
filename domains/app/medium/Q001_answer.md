# Q001: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: IntentService.java
在 `onStart()` 方法中，錯誤地移除了待處理的消息，導致後續 Intent 被丟棄。

### Bug 2: HandlerThread.java
在 `getLooper()` 方法中，即使 Looper 已經初始化，仍然進入等待，導致消息處理延遲。

## Bug 1 位置

`frameworks/base/core/java/android/app/IntentService.java`

```java
@Override
public void onStart(@Nullable Intent intent, int startId) {
    Message msg = mServiceHandler.obtainMessage();
    msg.arg1 = startId;
    msg.obj = intent;
    // BUG: 移除了待處理的消息
    mServiceHandler.removeMessages(0);
    mServiceHandler.sendMessage(msg);
}
```

## Bug 2 位置

`frameworks/base/core/java/android/os/HandlerThread.java`

```java
public Looper getLooper() {
    if (!isAlive()) {
        return null;
    }

    boolean wasInterrupted = false;

    synchronized (this) {
        // BUG: 缺少 mLooper != null 的檢查，即使已初始化也會 wait
        while (isAlive()) {  // 原本應該是 while (isAlive() && mLooper == null)
            try {
                wait();
            } catch (InterruptedException e) {
                wasInterrupted = true;
            }
        }
    }
    // ...
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 IntentService.onStart 中
Log.d("IntentService", "onStart called, startId=" + startId);

// 在 ServiceHandler.handleMessage 中  
Log.d("IntentService", "handleMessage called, startId=" + msg.arg1);

// 在 HandlerThread.getLooper 中
Log.d("HandlerThread", "getLooper called, mLooper=" + mLooper);
```

2. **觀察 log**:
```
D IntentService: onStart called, startId=1
D IntentService: onStart called, startId=2
D IntentService: onStart called, startId=3
D IntentService: handleMessage called, startId=3   // 只有最後一個！
```

3. **定位問題**: 
   - `removeMessages(0)` 移除了所有待處理的消息
   - HandlerThread 的 getLooper() 可能會無限等待

## 問題分析

### Bug 1 分析
每次 onStart 都會移除隊列中的消息，只有最後一個 startId=3 的消息能被處理。

### Bug 2 分析
getLooper() 沒有正確檢查 mLooper 是否已初始化，可能導致 ServiceHandler 創建延遲。

## 正確代碼

### 修復 Bug 1 (IntentService.java)
```java
@Override
public void onStart(@Nullable Intent intent, int startId) {
    Message msg = mServiceHandler.obtainMessage();
    msg.arg1 = startId;
    msg.obj = intent;
    mServiceHandler.sendMessage(msg);  // 不要 removeMessages
}
```

### 修復 Bug 2 (HandlerThread.java)
```java
public Looper getLooper() {
    if (!isAlive()) {
        return null;
    }

    synchronized (this) {
        while (isAlive() && mLooper == null) {  // 加上 mLooper == null 檢查
            try {
                wait();
            } catch (InterruptedException e) {
                // ...
            }
        }
    }
    return mLooper;
}
```

## 修復驗證

```bash
atest android.app.cts.IntentServiceTest#testIntents
```

## 難度分類理由

**Medium** - 需要理解 Handler/Message 機制和 HandlerThread 的初始化流程，加 log 追蹤消息流向才能定位問題，涉及兩個檔案的協作問題。
