# Q004 答案解析

## 問題根因
`getPath()` 方法直接返回 `null`，而不是從 `mPath` 對象獲取絕對路徑。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageVolume.java`

## 修復方法
返回 `mPath.getAbsolutePath()` 而不是 `null`。

## 原始代碼
```java
/** @hide */
@UnsupportedAppUsage
public String getPath() {
    return null;  // Bug: 返回 null
}
```

## 修復後代碼
```java
/** @hide */
@UnsupportedAppUsage
public String getPath() {
    return mPath.getAbsolutePath();
}
```

## 知識點
1. `mPath` 是 `File` 類型，表示存儲卷的實際路徑
2. `getAbsolutePath()` 返回完整的文件系統路徑
3. 主存儲卷路徑通常是 `/storage/emulated/0`

## 調試技巧
1. 看到 NullPointerException，首先檢查可能返回 null 的方法
2. 對比預期行為和實際行為
3. 檢查成員變量是否正確使用
