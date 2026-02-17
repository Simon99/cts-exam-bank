# Q006: Address.hasLatitude() Returns Wrong State After clearLatitude()

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.AddressTest#testAccessLatitude
java.lang.AssertionError: 
Expected: false
Actual: true
    at android.location.cts.none.AddressTest.testAccessLatitude(AddressTest.java:125)
```

## 失敗的測試代碼片段

```java
address.setLatitude(latitude);
assertTrue(address.hasLatitude());
assertEquals(latitude, address.getLatitude(), DELTA);

address.clearLatitude();
assertFalse(address.hasLatitude());  // ← 這裡失敗，仍返回 true
```

## 問題描述

呼叫 `clearLatitude()` 後，`hasLatitude()` 應該返回 `false`，但實際仍返回 `true`。

## 相關源碼位置

- `frameworks/base/location/java/android/location/Address.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
