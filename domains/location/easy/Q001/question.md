# Q001: Location.hasAltitude() Always Returns False

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.LocationTest#testValues
java.lang.AssertionError: 
Expected: true
Actual: false
    at android.location.cts.none.LocationTest.testValues(LocationTest.java:113)
```

## 失敗的測試代碼片段

```java
l.setAltitude(100);
assertThat(l.hasAltitude()).isTrue();  // ← 這裡失敗
assertThat(l.getAltitude()).isEqualTo(100);
```

## 問題描述

當呼叫 `Location.setAltitude()` 設定高度後，`hasAltitude()` 應該返回 `true`，但測試顯示返回的是 `false`。

## 相關源碼位置

- `frameworks/base/core/java/android/location/Location.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
