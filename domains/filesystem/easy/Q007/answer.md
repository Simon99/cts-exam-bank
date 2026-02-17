# Q007 答案解析

## 問題根因
在 `writeToParcel()` 方法中，`mPrimary` 被錯誤地寫入為 `0`（false），
而不是根據實際值寫入。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageVolume.java`

## 修復方法
將硬編碼的 `0` 改為根據 `mPrimary` 的值寫入。

## 原始代碼
```java
@Override
public void writeToParcel(Parcel parcel, int flags) {
    parcel.writeString(mId);
    parcel.writeString(mPath.getAbsolutePath());
    parcel.writeString(mInternalPath.getAbsolutePath());
    parcel.writeString(mDescription);
    parcel.writeInt(0);  // Bug: 應該是 mPrimary ? 1 : 0
    // ...
}
```

## 修復後代碼
```java
@Override
public void writeToParcel(Parcel parcel, int flags) {
    parcel.writeString(mId);
    parcel.writeString(mPath.getAbsolutePath());
    parcel.writeString(mInternalPath.getAbsolutePath());
    parcel.writeString(mDescription);
    parcel.writeInt(mPrimary ? 1 : 0);
    // ...
}
```

## 知識點
1. `Parcelable` 是 Android 的高效序列化機制
2. 寫入和讀取順序必須完全一致
3. 布爾值通常用 `int`（0/1）表示

## 調試技巧
1. 對比序列化前後的對象值
2. 檢查 `writeToParcel()` 和構造函數的字段順序
3. 注意布爾值的序列化方式
