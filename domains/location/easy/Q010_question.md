# Q010: LocationRequest IllegalArgumentException for Negative Interval Missing

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.LocationRequestTest#testBuild_IllegalInterval
org.testng.AssertionError: Expected IllegalArgumentException to be thrown but nothing was thrown
    at android.location.cts.none.LocationRequestTest.testBuild_IllegalInterval(LocationRequestTest.java:127)
```

## 失敗的測試代碼片段

```java
@Test
public void testBuild_IllegalInterval() {
    assertThrows(
            IllegalArgumentException.class,
            () -> new LocationRequest.Builder(-1));  // ← 沒有拋出異常
}
```

## 問題描述

當傳入負數 interval（如 -1）給 `LocationRequest.Builder` 建構子時，應該拋出 `IllegalArgumentException`，但實際上沒有拋出。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationRequest.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
