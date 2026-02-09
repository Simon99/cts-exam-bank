# Q008 [Hard]: Location Flush Timeout During Provider Transition

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testFlushDuringProviderChange
java.util.concurrent.TimeoutException: Flush completion not received within 10 seconds
    at android.location.cts.fine.LocationManagerFineTest.testFlushDuringProviderChange(LocationManagerFineTest.java:1345)
```

## 失敗的測試代碼片段

```java
@Test
public void testFlushDuringProviderChange() throws Exception {
    // 設定批次位置請求
    LocationRequest request = new LocationRequest.Builder(1000)
        .setMaxUpdateDelayMillis(60000)  // 批次模式
        .build();
    
    AtomicBoolean flushComplete = new AtomicBoolean(false);
    LocationListener listener = new LocationListener() {
        @Override
        public void onLocationChanged(List<Location> locations) {}
        
        @Override
        public void onFlushComplete(int requestCode) {
            if (requestCode == 42) {
                flushComplete.set(true);
            }
        }
    };
    
    mManager.requestLocationUpdates(TEST_PROVIDER, request, DIRECT_EXECUTOR, listener);
    
    // 發送一些位置
    for (int i = 0; i < 3; i++) {
        mManager.setTestProviderLocation(TEST_PROVIDER, createLocation(TEST_PROVIDER, 37.0 + i * 0.001, -122.0));
    }
    
    // 在 provider 狀態變更期間請求 flush
    mManager.setTestProviderEnabled(TEST_PROVIDER, false);
    mManager.requestFlush(TEST_PROVIDER, listener, 42);  // 請求 flush
    mManager.setTestProviderEnabled(TEST_PROVIDER, true);
    
    // 等待 flush 完成
    Thread.sleep(10000);
    assertThat(flushComplete.get()).isTrue();  // ← 失敗：超時
}
```

## 問題描述

`requestFlush()` 用於強制立即傳送所有已緩存的位置。但在 provider 狀態變更期間（啟用/停用切換）請求 flush，回調永遠不會被觸發。

## 相關源碼位置

呼叫鏈：
1. `frameworks/base/location/java/android/location/LocationManager.java`
2. `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`
3. `frameworks/base/services/core/java/com/android/server/location/provider/AbstractLocationProvider.java`
4. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssLocationProvider.java`

## 調試提示

1. `requestFlush()` 的實作流程？
2. Provider 停用時，pending flush requests 如何處理？
3. 狀態變更時 flush 請求是否被正確保留或取消？

## 任務

找出 flush 回調在 provider 狀態變更時丟失的原因。
