# Q001 答案解析

## 問題根因
在 `StorageVolume.java` 的 `isPrimary()` 方法中，返回值被錯誤地寫為 `false`。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageVolume.java`

## 修復方法
將 `isPrimary()` 方法的返回值從 `false` 改回 `mPrimary`。

## 原始代碼
```java
public boolean isPrimary() {
    return false;  // Bug: 應該返回 mPrimary
}
```

## 修復後代碼
```java
public boolean isPrimary() {
    return mPrimary;
}
```

## 知識點
1. `StorageVolume` 是描述存儲卷信息的類
2. `mPrimary` 標記該卷是否為主存儲
3. 主存儲是設備默認的外部存儲位置

## 調試技巧
1. 從 CTS 測試代碼入手，找到 `isPrimary()` 調用
2. 檢查 `StorageVolume.isPrimary()` 的實現
3. 發現返回值被硬編碼為 `false`
