# Q004: LocationRequest Builder Returns Wrong Default Quality

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.LocationRequestTest#testBuild_Defaults
java.lang.AssertionError: 
Expected: 102
Actual: 100
    at android.location.cts.none.LocationRequestTest.testBuild_Defaults(LocationRequestTest.java:38)
```

## 失敗的測試代碼片段

```java
LocationRequest request = new LocationRequest.Builder(0).build();
assertThat(request.getQuality()).isEqualTo(LocationRequest.QUALITY_BALANCED_POWER_ACCURACY);
// QUALITY_BALANCED_POWER_ACCURACY = 102, 但實際返回 100 (QUALITY_HIGH_ACCURACY)
```

## 問題描述

新建的 `LocationRequest` 預設 quality 應該是 `QUALITY_BALANCED_POWER_ACCURACY` (102)，但實際返回的是 `QUALITY_HIGH_ACCURACY` (100)。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationRequest.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
