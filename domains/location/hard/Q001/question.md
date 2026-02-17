# Q001 [Hard]: Location Fusing Accuracy Degradation

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testFusedProviderAccuracy
java.lang.AssertionError: 
Expected fused location accuracy: <= 10.0 meters
Actual accuracy: 1000.0 meters
    at android.location.cts.fine.LocationManagerFineTest.testFusedProviderAccuracy(LocationManagerFineTest.java:567)
```

## 失敗的測試代碼片段

```java
@Test
public void testFusedProviderAccuracy() throws Exception {
    // 設定一個高精度的 GPS 位置
    Location gpsLocation = createLocation(GPS_PROVIDER, 37.422, -122.084);
    gpsLocation.setAccuracy(5.0f);  // 5 米精度
    mManager.setTestProviderLocation(GPS_PROVIDER, gpsLocation);
    
    // 請求 fused provider 的位置
    LocationListenerCapture capture = new LocationListenerCapture(mContext);
    LocationRequest request = new LocationRequest.Builder(1000)
        .setQuality(LocationRequest.QUALITY_HIGH_ACCURACY)
        .build();
    
    mManager.requestLocationUpdates(FUSED_PROVIDER, request, DIRECT_EXECUTOR, capture);
    
    Location fusedLocation = capture.getNextLocation(5000);
    assertThat(fusedLocation).isNotNull();
    
    // Fused 位置的精度應該接近或優於輸入的 GPS 精度
    assertThat(fusedLocation.getAccuracy()).isAtMost(10.0f);  // ← 失敗：1000 米
}
```

## 問題描述

Fused location provider 應該融合多個來源（GPS、Network）產生最佳精度的位置，但輸出的位置精度異常差（1000 米），即使輸入的 GPS 位置精度只有 5 米。

## 相關源碼位置

呼叫鏈（請按順序追蹤）：
1. `frameworks/base/location/java/android/location/LocationManager.java`
2. `frameworks/base/services/core/java/com/android/server/location/LocationManagerService.java`
3. `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`
4. `frameworks/base/services/core/java/com/android/server/location/fudger/LocationFudger.java`

## 調試提示

1. 位置從 provider 到 listener 的完整路徑是什麼？
2. `LocationFudger` 的作用是什麼？它何時會被使用？
3. 精度值是否被錯誤地覆蓋？

## 任務

追蹤呼叫鏈，找出導致精度退化的 bug（可能涉及多個檔案）並修復。
