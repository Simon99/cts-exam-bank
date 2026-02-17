# Q002 答案解析

## Bug 位置

`frameworks/base/core/java/android/location/Location.java` 的 `setBearing()` 方法

## Bug 描述

在處理負數 bearing 時，條件判斷方向錯誤。

原始正確代碼：
```java
public void setBearing(float bearingDegrees) {
    Preconditions.checkArgument(Float.isFinite(bearingDegrees));
    float modBearing = bearingDegrees % 360f + 0f;
    if (modBearing < 0) {      // 正確：當結果為負數時加 360
        modBearing += 360f;
    }
    mBearingDegrees = modBearing;
    mFieldsMask |= HAS_BEARING_MASK;
}
```

Bug 代碼：
```java
public void setBearing(float bearingDegrees) {
    Preconditions.checkArgument(Float.isFinite(bearingDegrees));
    float modBearing = bearingDegrees % 360f + 0f;
    if (modBearing > 0) {      // 錯誤：條件反了
        modBearing += 360f;
    }
    mBearingDegrees = modBearing;
    mFieldsMask |= HAS_BEARING_MASK;
}
```

## 修復方式

將 `if (modBearing > 0)` 改回 `if (modBearing < 0)`。

## 調試思路

1. 測試期望 -371 度正規化為 349 度，但實際得到 11 度
2. -371 % 360 = -11
3. 如果條件是 `> 0`，則 -11 不會加 360，直接使用 -11 + 0 = -11... 但實際顯示 11
4. 仔細看，如果 modBearing > 0 時加 360，正數值會變更大，不符合 [0, 360) 範圍
5. 確認條件判斷反了

## 涉及檔案

1. `frameworks/base/core/java/android/location/Location.java`
