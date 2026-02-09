# Q003: Geocoder.getFromLocation() Always Returns Empty List

## CTS 測試失敗現象

```
FAIL: android.location.cts.geocode.GeocoderTest#testGetFromLocation
java.lang.AssertionError: 
Expected: not empty list
Actual: []
    at android.location.cts.geocode.GeocoderTest.testGetFromLocation(GeocoderTest.java:65)
```

## 失敗的測試代碼片段

```java
@Test
public void testGetFromLocation() throws Exception {
    Geocoder geocoder = new Geocoder(mContext, Locale.US);
    
    // 使用 Google 總部座標進行反向地理編碼
    double latitude = 37.422;
    double longitude = -122.084;
    
    CountDownLatch latch = new CountDownLatch(1);
    List<Address> results = new ArrayList<>();
    
    geocoder.getFromLocation(latitude, longitude, 5, new Geocoder.GeocodeListener() {
        @Override
        public void onGeocode(List<Address> addresses) {
            results.addAll(addresses);
            latch.countDown();
        }
        
        @Override
        public void onError(String errorMessage) {
            latch.countDown();
        }
    });
    
    assertTrue(latch.await(30, TimeUnit.SECONDS));
    assertThat(results).isNotEmpty();  // ← 失敗：results 為空
}
```

## 問題描述

`Geocoder.getFromLocation()` 呼叫成功完成（沒有錯誤），但總是返回空的地址列表。Geocoder 是一個代理服務，實際工作由系統的 Geocode Provider 完成。

## 相關源碼位置

- `frameworks/base/location/java/android/location/Geocoder.java` — 客戶端 API
- `frameworks/base/services/core/java/com/android/server/location/provider/proxy/ProxyGeocodeProvider.java` — 代理 Provider

## 調試提示

1. `Geocoder` 如何呼叫 `ProxyGeocodeProvider`？
2. 結果是如何從遠端服務傳回客戶端的？

## 任務

找出地理編碼結果無法正確返回的 bug 並修復。
