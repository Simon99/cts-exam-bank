# Q008 答案解析

## 問題根因
`describeContents()` 返回了 `1`（`CONTENTS_FILE_DESCRIPTOR`），
但 `StorageVolume` 不包含 FileDescriptor，應該返回 `0`。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageVolume.java`

## 修復方法
將返回值從 `1` 改為 `0`。

## 原始代碼
```java
@Override
public int describeContents() {
    return 1;  // Bug: 應該返回 0
}
```

## 修復後代碼
```java
@Override
public int describeContents() {
    return 0;
}
```

## 知識點
1. `describeContents()` 是 `Parcelable` 接口的必需方法
2. 返回 0 表示沒有特殊對象
3. 返回 `CONTENTS_FILE_DESCRIPTOR (1)` 表示包含文件描述符
4. `StorageVolume` 只包含基本數據類型和 String，不含 FD

## 調試技巧
1. 了解 `Parcelable` 接口的語義
2. 檢查類是否包含 FileDescriptor 或 Binder
3. 大多數普通 Parcelable 返回 0
