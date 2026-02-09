# Q002: 答案解析

## 問題根源

本題有三個 Bug，分布在不同檔案的權限處理鏈中：

### Bug 1: GrantUri.java
`equals()` 方法缺少 `sourceUserId` 的比較，導致不同用戶的 URI 權限被混淆。

### Bug 2: UriGrantsManagerService.java
權限查找時使用的 key 與存儲時不一致。

### Bug 3: ContentProviderHelper.java
權限檢查邏輯在某些情況下跳過了 URI grants 檢查。

## Bug 1 位置

`frameworks/base/services/core/java/com/android/server/uri/GrantUri.java`

```java
@Override
public boolean equals(Object o) {
    if (o instanceof GrantUri) {
        GrantUri other = (GrantUri) o;
        // BUG: 缺少 sourceUserId 比較
        return uri.equals(other.uri) && prefix == other.prefix;
        // 應該是: return uri.equals(other.uri) && (sourceUserId == other.sourceUserId)
        //         && prefix == other.prefix;
    }
    return false;
}
```

## Bug 2 位置

`frameworks/base/services/core/java/com/android/server/uri/UriGrantsManagerService.java`

```java
private UriPermission findUriPermission(int targetUid, GrantUri grantUri) {
    ArrayMap<GrantUri, UriPermission> targetUris = mGrantedUriPermissions.get(targetUid);
    if (targetUris != null) {
        // BUG: 使用錯誤的 sourceUserId 進行查找
        GrantUri searchKey = new GrantUri(0, grantUri.uri, grantUri.prefix);  // userId 固定為 0
        return targetUris.get(searchKey);
        // 應該使用 grantUri 本身作為 key
    }
    return null;
}
```

## Bug 3 位置

`frameworks/base/services/core/java/com/android/server/am/ContentProviderHelper.java`

```java
int checkContentProviderUriPermission(Uri uri, int uid, int modeFlags, int userId) {
    // BUG: 在某些快速路徑下跳過了 URI grants 檢查
    if (hasStaticPermission(uid)) {
        return PackageManager.PERMISSION_GRANTED;  // 提前返回
    }
    
    // URI grants 檢查被跳過
    // return mUgmInternal.checkUriPermission(...);
    return PackageManager.PERMISSION_DENIED;
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 GrantUri.equals 中
Log.d("GrantUri", "equals: this.userId=" + sourceUserId + 
      ", other.userId=" + other.sourceUserId + ", uri=" + uri);

// 在 UriGrantsManagerService.findUriPermission 中
Log.d("UriGrants", "findUriPermission: targetUid=" + targetUid + ", grantUri=" + grantUri);

// 在 ContentProviderHelper.checkContentProviderUriPermission 中
Log.d("ContentProviderHelper", "checkPermission: uid=" + uid + ", uri=" + uri);
```

2. **觀察 log**:
```
D UriGrants: grantUriPermission: storing with userId=0, uri=content://...
D GrantUri: equals: this.userId=10, other.userId=0  # 不匹配！
D ContentProviderHelper: checkPermission returning DENIED (fast path)
```

3. **定位問題**: userId 不一致 + 快速路徑跳過檢查

## 問題分析

### Bug 1 分析
GrantUri.equals() 沒有比較 sourceUserId，導致存儲時用 userId=0 的 key，查找時用 userId=10 的 key，無法匹配。

### Bug 2 分析
UriGrantsManagerService 在構建查找 key 時固定使用 userId=0，與實際存儲的 key 不匹配。

### Bug 3 分析
ContentProviderHelper 的快速路徑在檢查到沒有靜態權限時直接返回 DENIED，跳過了 URI grants 檢查。

## 正確代碼

### 修復 Bug 1 (GrantUri.java)
```java
@Override
public boolean equals(Object o) {
    if (o instanceof GrantUri) {
        GrantUri other = (GrantUri) o;
        return uri.equals(other.uri) && (sourceUserId == other.sourceUserId)
                && prefix == other.prefix;
    }
    return false;
}
```

### 修復 Bug 2 (UriGrantsManagerService.java)
```java
private UriPermission findUriPermission(int targetUid, GrantUri grantUri) {
    ArrayMap<GrantUri, UriPermission> targetUris = mGrantedUriPermissions.get(targetUid);
    if (targetUris != null) {
        return targetUris.get(grantUri);  // 直接使用 grantUri
    }
    return null;
}
```

### 修復 Bug 3 (ContentProviderHelper.java)
```java
int checkContentProviderUriPermission(Uri uri, int uid, int modeFlags, int userId) {
    if (hasStaticPermission(uid)) {
        return PackageManager.PERMISSION_GRANTED;
    }
    // 繼續檢查 URI grants
    return mUgmInternal.checkUriPermission(new GrantUri(userId, uri, false), 
            uid, modeFlags);
}
```

## 修復驗證

```bash
atest android.content.cts.ContentProviderClientTest#testGrantUriPermission
```

## 難度分類理由

**Hard** - 需要理解跨進程權限模型、URI grants 機制，追蹤跨越三個系統服務文件的權限檢查流程，涉及 HashMap 的 equals/hashCode 契約問題。
