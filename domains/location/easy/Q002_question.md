# Q002: Location.getBearing() Returns Wrong Value

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.LocationTest#testValues
java.lang.AssertionError: 
Expected: 349.0
Actual: 11.0
    at android.location.cts.none.LocationTest.testValues(LocationTest.java:142)
```

## 失敗的測試代碼片段

```java
l.setBearing(-371);
assertThat(l.getBearing()).isEqualTo(349f);  // ← 這裡失敗，返回 11.0
```

## 問題描述

當設定負數 bearing 時，`getBearing()` 應該返回正確正規化後的值。`-371` 度應該正規化為 `349` 度（-371 + 360 = -11，再 + 360 = 349）。

## 相關源碼位置

- `frameworks/base/core/java/android/location/Location.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
