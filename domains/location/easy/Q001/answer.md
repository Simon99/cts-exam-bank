# Q001 答案解析

## Bug 位置

`frameworks/base/core/java/android/location/Location.java` 的 `setAltitude()` 方法

## Bug 描述

在 `setAltitude()` 方法中，設定 `mFieldsMask` 時使用了錯誤的 mask。

原始正確代碼：
```java
public void setAltitude(@FloatRange double altitudeMeters) {
    mAltitudeMeters = altitudeMeters;
    mFieldsMask |= HAS_ALTITUDE_MASK;  // 正確
}
```

Bug 代碼：
```java
public void setAltitude(@FloatRange double altitudeMeters) {
    mAltitudeMeters = altitudeMeters;
    mFieldsMask |= HAS_SPEED_MASK;  // 錯誤：使用了 HAS_SPEED_MASK
}
```

## 修復方式

將 `HAS_SPEED_MASK` 改回 `HAS_ALTITUDE_MASK`。

## 調試思路

1. 測試失敗訊息顯示 `hasAltitude()` 返回 `false`
2. 查看 `hasAltitude()` 方法，發現它檢查 `(mFieldsMask & HAS_ALTITUDE_MASK) != 0`
3. 查看 `setAltitude()` 方法，發現它設定的 mask 不正確
4. 修改 mask 為正確的 `HAS_ALTITUDE_MASK`

## 涉及檔案

1. `frameworks/base/core/java/android/location/Location.java`
