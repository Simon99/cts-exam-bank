# Q005: GnssStatus.getSatelliteCount() Returns Wrong Value

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.GnssStatusTest#testBuilder_ClearSatellites
java.lang.AssertionError: 
Expected: 0
Actual: 1
    at android.location.cts.none.GnssStatusTest.testBuilder_ClearSatellites(GnssStatusTest.java:55)
```

## 失敗的測試代碼片段

```java
GnssStatus.Builder builder = new GnssStatus.Builder();
builder.addSatellite(...);
builder.clearSatellites();

GnssStatus status = builder.build();
assertEquals(0, status.getSatelliteCount());  // ← 期望 0，實際 1
```

## 問題描述

呼叫 `clearSatellites()` 後，建構出的 `GnssStatus` 應該沒有衛星（count = 0），但實際上 count 仍為 1。

## 相關源碼位置

- `frameworks/base/core/java/android/location/GnssStatus.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
