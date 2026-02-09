# Q004: LocationRequest.getQuality() Returns Wrong Value

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.LocationRequestTest#testLocationRequestQuality
java.lang.AssertionError: 
Expected: QUALITY_HIGH_ACCURACY (100)
Actual: QUALITY_LOW_POWER (104)
    at android.location.cts.none.LocationRequestTest.testLocationRequestQuality(LocationRequestTest.java:132)
```

## 失敗的測試代碼片段

```java
@Test
public void testLocationRequestQuality() {
    LocationRequest request = new LocationRequest.Builder(5000)
        .setQuality(LocationRequest.QUALITY_HIGH_ACCURACY)
        .build();
    
    assertThat(request.getQuality()).isEqualTo(LocationRequest.QUALITY_HIGH_ACCURACY);
    
    // 註冊位置更新並檢查伺服器端收到的請求
    mManager.requestLocationUpdates(GPS_PROVIDER, request, 
            DIRECT_EXECUTOR, mLocationListener);
    
    ProviderRequest providerRequest = getProviderRequest(GPS_PROVIDER);
    assertThat(providerRequest.getQuality())
        .isEqualTo(LocationRequest.QUALITY_HIGH_ACCURACY);  // ← 失敗
}
```

## 問題描述

客戶端設定 `QUALITY_HIGH_ACCURACY`，但伺服器端處理請求時使用的是 `QUALITY_LOW_POWER`。Quality 設定影響定位的精度和功耗策略。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationRequest.java` — Request 定義
- `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java` — 請求合併處理

## 調試提示

1. Quality 值是如何從 LocationRequest 傳遞到 ProviderRequest 的？
2. 多個請求合併時，quality 是如何決定的？

## 任務

找出 quality 值被錯誤處理的 bug 並修復。
