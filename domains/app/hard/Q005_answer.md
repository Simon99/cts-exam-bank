# Q005: 答案解析

## 問題根源

本題有三個 Bug，分布在 PendingIntent 處理鏈的不同階段：

### Bug 1: PendingIntentRecord.java
`Key.equals()` 方法缺少 `requestCode` 的比較，導致不同 requestCode 的 PendingIntent 被視為相同。

### Bug 2: PendingIntentController.java
`getIntentSender()` 在查找現有記錄時添加了錯誤的 UID 檢查，導致匹配邏輯異常。

### Bug 3: PendingIntent.java
`getActivityAsUser()` 方法將 requestCode 硬編碼為 0，忽略了實際傳入的參數。

## Bug 1 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/am/PendingIntentRecord.java`

```java
final static class Key {
    final int requestCode;  // 用於區分同一 Activity 的多個 PendingIntent
    // ...

    @Override
    public boolean equals(Object otherObj) {
        // ...
        if (!Objects.equals(who, other.who)) return false;
        
        // BUG: 缺少 requestCode 比較！
        // if (requestCode != other.requestCode) return false;
        
        if (requestIntent != other.requestIntent) {
            // Intent 比較...
        }
    }
}
```

## Bug 2 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/am/PendingIntentController.java`

```java
public PendingIntentRecord getIntentSender(...) {
    synchronized (mLock) {
        // ...
        ref = mIntentSenderRecords.get(key);
        PendingIntentRecord rec = ref != null ? ref.get() : null;
        
        // BUG: 添加了不應該存在的 UID 檢查
        if (rec != null && callingUid == rec.uid) {
            // 這導致不同 UID 無法正確找到匹配的記錄
            // 原本應該只檢查 rec != null
        }
    }
}
```

## Bug 3 位置

**檔案**: `frameworks/base/core/java/android/app/PendingIntent.java`

```java
public static PendingIntent getActivityAsUser(Context context, int requestCode,
        @NonNull Intent intent, int flags, Bundle options, UserHandle user) {
    // ...
    IIntentSender target =
        ActivityManager.getService().getIntentSenderWithFeature(
            INTENT_SENDER_ACTIVITY, packageName,
            context.getAttributionTag(), null, null, 
            0,  // BUG: 應該是 requestCode，卻寫成 0
            new Intent[] { intent },
            // ...
        );
}
```

## 診斷步驟

1. **添加 log 追蹤 PendingIntent 創建**:
```java
// PendingIntentRecord.java Key.equals()
Log.d("PendingIntent", "Key.equals: this.requestCode=" + requestCode 
    + " other.requestCode=" + other.requestCode);

// PendingIntent.java getActivityAsUser()
Log.d("PendingIntent", "getActivityAsUser: requestCode param=" + requestCode);

// PendingIntentController.java getIntentSender()
Log.d("PendingIntent", "getIntentSender: callingUid=" + callingUid 
    + " rec.uid=" + (rec != null ? rec.uid : "null"));
```

2. **觀察 log**:
```
# App 創建兩個不同 requestCode 的 PendingIntent
D PendingIntent: getActivityAsUser: requestCode param=100
D PendingIntent: getIntentSender: requestCode received=0  # Bug 3!

D PendingIntent: getActivityAsUser: requestCode param=200  
D PendingIntent: getIntentSender: requestCode received=0  # Bug 3!

D PendingIntent: Key.equals: this.requestCode=0 other.requestCode=0 result=true  # Bug 1!
```

3. **問題定位**: 
   - requestCode 在客戶端就被丟棄了
   - Key.equals 不比較 requestCode
   - 導致所有 PendingIntent 被視為相同

## 問題分析

### Bug 1 分析
`requestCode` 的設計目的：
1. 允許同一個 Activity 持有多個不同的 PendingIntent
2. 用於 `Activity.onActivityResult()` 中區分不同的請求
3. 是 PendingIntent 唯一性的關鍵組成部分

### Bug 2 分析
getIntentSender 添加的 UID 檢查會導致：
- 同一 App 的不同進程可能找不到匹配的記錄
- FLAG_UPDATE_CURRENT 行為異常

### Bug 3 分析
客戶端將 requestCode 硬編碼為 0：
- 所有 PendingIntent 都使用相同的 requestCode
- 配合 Bug 1，導致所有相似 Intent 的 PendingIntent 被合併

## 正確代碼

### 修復 Bug 1 (PendingIntentRecord.java)
```java
@Override
public boolean equals(Object otherObj) {
    // ...
    if (!Objects.equals(who, other.who)) return false;
    
    // 正確：必須比較 requestCode
    if (requestCode != other.requestCode) return false;
    
    if (requestIntent != other.requestIntent) {
        // ...
    }
}
```

### 修復 Bug 2 (PendingIntentController.java)
```java
ref = mIntentSenderRecords.get(key);
PendingIntentRecord rec = ref != null ? ref.get() : null;

// 正確：只檢查記錄是否存在
if (rec != null) {
    if (!cancelCurrent) {
        // ...
    }
}
```

### 修復 Bug 3 (PendingIntent.java)
```java
IIntentSender target =
    ActivityManager.getService().getIntentSenderWithFeature(
        INTENT_SENDER_ACTIVITY, packageName,
        context.getAttributionTag(), null, null, 
        requestCode,  // 正確：使用傳入的 requestCode
        new Intent[] { intent },
        // ...
    );
```

## 修復驗證

```bash
atest android.app.cts.PendingIntentTest#testPendingIntentIdentityIsolation
atest android.app.cts.PendingIntentTest#testRequestCodeUniqueness
atest com.android.server.am.PendingIntentRecordTest
```

## 難度分類理由

**Hard** - 需要理解 PendingIntent 從客戶端到服務端的完整流程，包括：
1. 客戶端 API（PendingIntent.java）
2. 服務端管理（PendingIntentController.java）
3. 記錄匹配（PendingIntentRecord.java Key.equals）

Bug 分布在呼叫鏈的三個不同層次，需要完整追蹤才能定位所有問題。
