# Q009 答案解析

## Bug 位置

`frameworks/base/core/java/android/location/Location.java` 的 `set()` 方法

## Bug 描述

`set()` 方法漏掉複製 `mProvider` 欄位。

原始正確代碼：
```java
public void set(@NonNull Location location) {
    mFieldsMask = location.mFieldsMask;
    mProvider = location.mProvider;  // 正確複製 provider
    mTimeMs = location.mTimeMs;
    // ... 其他欄位
}
```

Bug 代碼：
```java
public void set(@NonNull Location location) {
    mFieldsMask = location.mFieldsMask;
    // mProvider = location.mProvider;  // 這行被刪除了
    mTimeMs = location.mTimeMs;
    // ... 其他欄位
}
```

## 修復方式

在 `set()` 方法中加回 `mProvider = location.mProvider;`

## 調試思路

1. 測試顯示 set() 後兩個 Location 不相等
2. 查看 Location.set() 方法的欄位複製
3. 逐一檢查每個欄位是否都有複製
4. 找到漏掉的 mProvider 欄位

## 涉及檔案

1. `frameworks/base/core/java/android/location/Location.java`
