# Q005 答案解析

## Bug 位置

`frameworks/base/core/java/android/location/GnssStatus.java` 的 Builder.clearSatellites() 方法

## Bug 描述

`clearSatellites()` 方法沒有正確清除衛星計數。

原始正確代碼：
```java
public Builder clearSatellites() {
    mSatelliteCount = 0;
    // 其他清理操作...
    return this;
}
```

Bug 代碼：
```java
public Builder clearSatellites() {
    // mSatelliteCount = 0;  // 這行被註釋掉或刪除了
    // 只清理了其他數據，但沒有重置計數
    return this;
}
```

## 修復方式

確保 `clearSatellites()` 方法正確重置 `mSatelliteCount = 0`。

## 調試思路

1. 測試顯示 clearSatellites() 後 getSatelliteCount() 仍返回 1
2. 查看 GnssStatus.Builder.clearSatellites() 方法
3. 發現沒有重置衛星計數

## 涉及檔案

1. `frameworks/base/core/java/android/location/GnssStatus.java`
