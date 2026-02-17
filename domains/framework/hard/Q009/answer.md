# Q009 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/ContentResolver.java`

```java
public void notifyChange(@NonNull Uri uri, @Nullable ContentObserver observer,
        @NotifyFlags int flags) {
    Objects.requireNonNull(uri, "uri");
    notifyChange(
            ContentProvider.getUriWithoutUserId(uri),
            observer,
            flags,  // BUG: flags 應該正確傳遞，但被修改為錯誤值
            ContentProvider.getUserIdFromUri(uri, mContext.getUserId()));
}

// 內部方法
public void notifyChange(@NonNull Uri[] uris, ContentObserver observer, @NotifyFlags int flags,
        @UserIdInt int userHandle) {
    try {
        getContentService().notifyChange(
                uris, observer == null ? null : observer.getContentObserver(),
                observer != null && observer.deliverSelfNotifications(), 
                flags,  // flags 傳遞到這裡
                userHandle, mTargetSdkVersion, mContext.getPackageName());
    } catch (RemoteException e) {
        throw e.rethrowFromSystemServer();
    }
}
```

## 根本原因

1. `NOTIFY_SKIP_NOTIFY_FOR_DESCENDANTS` 的位元值是 `(1 << 1)` = 2
2. Bug patch 中將 flags 參數用位元「與」運算替代，導致只有部分 flags 被傳遞
3. 或者 flags 被錯誤地與其他值進行運算，丟失了 SKIP_DESCENDANTS 位元

## 修復方案

```java
public void notifyChange(@NonNull Uri uri, @Nullable ContentObserver observer,
        @NotifyFlags int flags) {
    Objects.requireNonNull(uri, "uri");
    // 確保 flags 完整傳遞，不進行任何位元運算修改
    notifyChange(
            ContentProvider.getUriWithoutUserId(uri),
            observer,
            flags,  // 直接傳遞，不做修改
            ContentProvider.getUserIdFromUri(uri, mContext.getUserId()));
}
```

## 涉及檔案

1. `frameworks/base/core/java/android/content/ContentResolver.java` - notifyChange() 方法
2. `frameworks/base/services/core/java/com/android/server/content/ContentService.java` - 服務端處理

## Flags 常量說明

```java
// ContentResolver.java 中的 flag 定義
public static final int NOTIFY_SYNC_TO_NETWORK = 1 << 0;        // 1
public static final int NOTIFY_SKIP_NOTIFY_FOR_DESCENDANTS = 1 << 1;  // 2
public static final int NOTIFY_INSERT = 1 << 2;                 // 4
public static final int NOTIFY_UPDATE = 1 << 3;                 // 8
public static final int NOTIFY_DELETE = 1 << 4;                 // 16
public static final int NOTIFY_NO_DELAY = 1 << 5;               // 32
```

## 難度分析

**Hard** - 需要理解：
- 位掩碼（bitmask）操作
- ContentResolver 到 ContentService 的調用鏈
- Observer 通知的層級關係

## CTS 測試意圖

驗證 notifyChange 的 flags 參數能正確影響通知行為，特別是 SKIP_NOTIFY_FOR_DESCENDANTS 應該防止子路徑的 observer 收到通知。
