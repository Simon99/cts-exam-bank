# Q003 答案解析

## Bug 位置

**主要檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
public void writeToParcel(Parcel out, int flags) {
    out.writeString8(mAction);
    Uri.writeToParcel(out, mData);
    out.writeString8(mType);
    out.writeInt(mFlags);
    // ...
    
    // BUG: ClipData 寫入但沒有保留 URI 權限關聯
    if (mClipData != null) {
        out.writeInt(1);
        mClipData.writeToParcel(out, flags);
    } else {
        out.writeInt(0);
    }
    
    // mContentUserHint 沒有被序列化
    // out.writeInt(mContentUserHint);  // 缺失
}
```

**相關問題** 在 `ClipData.java`:
```java
public void writeToParcel(Parcel dest, int flags) {
    mClipDescription.writeToParcel(dest, flags);
    final int N = mItems.size();
    dest.writeInt(N);
    for (int i = 0; i < N; i++) {
        ClipData.Item item = mItems.get(i);
        // BUG: 沒有保留 permission grant 信息
        item.writeToParcel(dest, flags);
    }
}
```

## 根本原因

1. `Intent.writeToParcel()` 沒有序列化 `mContentUserHint` 
2. `ClipData` 序列化時沒有保留 URI permission grant 信息
3. 這些信息在跨進程傳遞時丟失，導致接收方無權限訪問 URI

## 修復方案

```java
// Intent.java
public void writeToParcel(Parcel out, int flags) {
    // ... 其他字段
    if (mClipData != null) {
        out.writeInt(1);
        mClipData.writeToParcel(out, flags);
    } else {
        out.writeInt(0);
    }
    out.writeInt(mContentUserHint);  // 添加：序列化用戶提示
}

// ClipData.java - 確保 permission grants 被傳遞
// 這通常由 ActivityManagerService 在發送 Intent 時處理
```

## 涉及檔案

1. `frameworks/base/core/java/android/content/Intent.java` - Intent 序列化
2. `frameworks/base/core/java/android/content/ClipData.java` - ClipData 序列化
3. `frameworks/base/services/core/java/com/android/server/am/ActivityManagerService.java` - 權限授予

## 調試過程

1. 確認 ClipData 本身被正確序列化
2. 檢查 mFlags 是否包含權限 flag
3. 發現 mContentUserHint 丟失
4. 追蹤 AMS 中 URI 權限授予邏輯

## 難度分析

**Hard** - 涉及 Intent、ClipData 和權限系統三方交互
