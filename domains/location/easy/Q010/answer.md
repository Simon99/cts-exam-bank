# Q010 答案解析

## Bug 位置

`frameworks/base/location/java/android/location/LocationRequest.java` 的 Builder 建構子

## Bug 描述

Builder 建構子的參數驗證被移除。

原始正確代碼：
```java
public Builder(long intervalMillis) {
    Preconditions.checkArgument(intervalMillis >= 0);
    mIntervalMillis = intervalMillis;
}
```

Bug 代碼：
```java
public Builder(long intervalMillis) {
    // Preconditions.checkArgument(intervalMillis >= 0);  // 驗證被移除
    mIntervalMillis = intervalMillis;
}
```

## 修復方式

恢復 `Preconditions.checkArgument(intervalMillis >= 0)` 檢查。

## 調試思路

1. 測試期望傳入 -1 時拋出 IllegalArgumentException
2. 查看 LocationRequest.Builder 的建構子
3. 發現缺少參數驗證

## 涉及檔案

1. `frameworks/base/location/java/android/location/LocationRequest.java`
