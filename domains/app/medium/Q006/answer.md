# Q006: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: IntentService.java
在 `onStartCommand()` 中，三元運算符的條件邏輯被反轉了。

### Bug 2: Service.java
Service 基類的 `onStartCommand()` 默認返回值設置錯誤，影響了子類的行為。

## Bug 1 位置

`frameworks/base/core/java/android/app/IntentService.java`

```java
@Override
public int onStartCommand(@Nullable Intent intent, int flags, int startId) {
    onStart(intent, startId);
    // BUG: 條件反轉！mRedelivery=true 時反而返回 START_NOT_STICKY
    return mRedelivery ? START_NOT_STICKY : START_REDELIVER_INTENT;
    // 應該是: return mRedelivery ? START_REDELIVER_INTENT : START_NOT_STICKY;
}
```

## Bug 2 位置

`frameworks/base/core/java/android/app/Service.java`

```java
public @StartResult int onStartCommand(Intent intent, @StartArgFlags int flags, int startId) {
    // BUG: 默認返回 START_REDELIVER_INTENT 而非 START_STICKY
    onStart(intent, startId);
    return START_REDELIVER_INTENT;
    // 根據文檔應該是 START_STICKY
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 IntentService.onStartCommand 中
Log.d("IntentService", "onStartCommand: mRedelivery=" + mRedelivery);
int result = mRedelivery ? START_NOT_STICKY : START_REDELIVER_INTENT;
Log.d("IntentService", "onStartCommand returns: " + result);

// 在 IntentService.setIntentRedelivery 中
Log.d("IntentService", "setIntentRedelivery: enabled=" + enabled);
```

2. **觀察 log**:
```
D IntentService: setIntentRedelivery: enabled=true
D IntentService: onStartCommand: mRedelivery=true
D IntentService: onStartCommand returns: 1  // START_NOT_STICKY!
```

3. **定位問題**: 三元運算符的兩個分支互換了

## 問題分析

### Bug 1 分析
`mRedelivery ? START_NOT_STICKY : START_REDELIVER_INTENT` 應該是 `mRedelivery ? START_REDELIVER_INTENT : START_NOT_STICKY`。這是一個典型的「條件反轉」錯誤。

### Bug 2 分析
Service.java 的默認行為會影響不調用 super 的子類，或者在某些繼承場景下造成混淆。

## 正確代碼

### 修復 Bug 1 (IntentService.java)
```java
@Override
public int onStartCommand(@Nullable Intent intent, int flags, int startId) {
    onStart(intent, startId);
    return mRedelivery ? START_REDELIVER_INTENT : START_NOT_STICKY;
}
```

### 修復 Bug 2 (Service.java)
```java
public @StartResult int onStartCommand(Intent intent, @StartArgFlags int flags, int startId) {
    onStart(intent, startId);
    return START_STICKY;  // 使用正確的默認值
}
```

## 修復驗證

```bash
atest android.app.cts.IntentServiceTest#testRedelivery
```

## 難度分類理由

**Medium** - 需要理解 Service 的啟動模式和 Intent 重傳機制，追蹤配置標誌如何影響返回值，涉及兩個檔案的關聯問題。
