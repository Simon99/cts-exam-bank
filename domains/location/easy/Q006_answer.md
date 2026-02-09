# Q006 答案解析

## Bug 位置

`frameworks/base/location/java/android/location/Address.java` 的 `clearLatitude()` 方法

## Bug 描述

`clearLatitude()` 方法沒有正確設定 `mHasLatitude` 標誌為 false。

原始正確代碼：
```java
public void clearLatitude() {
    mHasLatitude = false;
}
```

Bug 代碼：
```java
public void clearLatitude() {
    mHasLatitude = true;  // 錯誤：應該是 false
}
```

或者：
```java
public void clearLatitude() {
    // mHasLatitude = false;  // 這行被刪除了
    mLatitude = 0;  // 只清除了值，但沒有更新標誌
}
```

## 修復方式

確保 `clearLatitude()` 設定 `mHasLatitude = false`。

## 調試思路

1. 測試顯示 clearLatitude() 後 hasLatitude() 仍返回 true
2. 查看 Address.clearLatitude() 方法
3. 發現標誌沒有正確設定為 false

## 涉及檔案

1. `frameworks/base/location/java/android/location/Address.java`
