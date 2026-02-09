# Q009 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
public @Nullable String resolveType(@NonNull Context context) {
    return resolveType(context.getContentResolver());
}

public @Nullable String resolveType(@NonNull ContentResolver resolver) {
    // BUG: 先檢查 data 的 type，應該先檢查 mType
    if (mData != null) {
        String dataType = resolver.getType(mData);
        if (dataType != null) {
            return dataType;
        }
    }
    return mType;
}
```

## 根本原因

`resolveType()` 方法的優先級順序錯誤。應該先檢查顯式設置的 `mType`，如果 mType 為空才從 data URI 推斷。但代碼先檢查了 data URI 的類型。

## 修復方案

```java
public @Nullable String resolveType(@NonNull ContentResolver resolver) {
    if (mType != null) {
        return mType;  // 優先返回顯式 type
    }
    if (mData != null) {
        return resolver.getType(mData);
    }
    return null;
}
```

## 調試過程

1. 顯式設置的 type 被 data URI 的 type 覆蓋
2. 說明優先級順序有問題
3. 追蹤 resolveType() 實現
4. 發現優先級順序錯誤

## 涉及檔案

- `frameworks/base/core/java/android/content/Intent.java`

## 難度分析

**Medium** - 需要理解 Intent type 解析的優先級規則
