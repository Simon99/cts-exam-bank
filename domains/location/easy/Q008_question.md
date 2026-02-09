# Q008: GnssMeasurement Parcel Roundtrip Fails

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.GnssMeasurementTest#testWriteToParcel
java.lang.AssertionError: 
Expected: 8.0
Actual: 0.0
    at android.location.cts.none.GnssMeasurementTest.testWriteToParcel(GnssMeasurementTest.java:56)
```

## 失敗的測試代碼片段

```java
GnssMeasurement measurement = new GnssMeasurement();
setTestValues(measurement);  // 設定 cn0DbHz = 8.0
Parcel parcel = Parcel.obtain();
measurement.writeToParcel(parcel, 0);
parcel.setDataPosition(0);
GnssMeasurement newMeasurement = GnssMeasurement.CREATOR.createFromParcel(parcel);
assertEquals(8.0, newMeasurement.getCn0DbHz(), DELTA);  // ← 期望 8.0，實際 0.0
```

## 問題描述

`GnssMeasurement` 物件序列化後再反序列化，`cn0DbHz` 值丟失（變成 0.0）。

## 相關源碼位置

- `frameworks/base/location/java/android/location/GnssMeasurement.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
