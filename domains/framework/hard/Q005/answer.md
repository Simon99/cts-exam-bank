# Q005 答案解析

## Bug 位置

**涉及多個檔案**

**檔案 1**: `frameworks/base/core/java/android/app/PendingIntent.java`
```java
public void send(Context context, int code, Intent intent) {
    // BUG: FLAG_IMMUTABLE 檢查在錯誤的位置
    send(context, code, intent, null, null, null, null);
}

private void sendInner(Context context, int code, Intent intent, ...) {
    // 檢查應該在這裡，但被遺漏
    if ((mFlags & FLAG_IMMUTABLE) == 0) {  // 條件寫反了
        // 允許修改
    }
    // ...
}
```

**檔案 2**: `frameworks/base/services/core/java/com/android/server/am/PendingIntentRecord.java`
```java
public int sendInner(int code, Intent intent, ...) {
    // BUG: fillIn intent 的組件沒有被驗證
    Intent finalIntent = key.requestIntent != null 
        ? new Intent(key.requestIntent) : new Intent();
    
    if (intent != null) {
        // 應該檢查 FLAG_IMMUTABLE
        finalIntent.fillIn(intent, key.flags);  // 直接 fillIn 不安全
    }
    // ...
}
```

**檔案 3**: `frameworks/base/core/java/android/content/Intent.java`
```java
public int fillIn(Intent other, int flags) {
    // BUG: 沒有檢查 PendingIntent 的 immutable 標誌
    if (other.mComponent != null) {
        mComponent = other.mComponent;  // 不應該覆蓋
    }
    // ...
}
```

## 根本原因

1. FLAG_IMMUTABLE 的檢查邏輯被錯誤地取反
2. PendingIntentRecord 在 sendInner 時沒有驗證 fillIn intent
3. Intent.fillIn 沒有受到 PendingIntent 安全標誌的約束

## 修復方案

```java
// PendingIntentRecord.java
public int sendInner(int code, Intent intent, ...) {
    Intent finalIntent = ...;
    
    if (intent != null && (key.flags & PendingIntent.FLAG_IMMUTABLE) == 0) {
        // 只有非 immutable 才允許 fillIn
        finalIntent.fillIn(intent, key.flags);
    }
    // ...
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/app/PendingIntent.java`
2. `frameworks/base/services/core/java/com/android/server/am/PendingIntentRecord.java`
3. `frameworks/base/core/java/android/content/Intent.java`

## 難度分析

**Hard** - 涉及安全機制，需要理解 Framework 和 System Server 的交互
