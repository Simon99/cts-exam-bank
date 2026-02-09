# Q006: LocationListener.onProviderEnabled Not Called

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testProviderEnabledCallback
java.lang.AssertionError: 
Expected onProviderEnabled callback to be invoked
    at android.location.cts.fine.LocationManagerFineTest.testProviderEnabledCallback(LocationManagerFineTest.java:523)
```

## 失敗的測試代碼片段

```java
@Test
public void testProviderEnabledCallback() throws Exception {
    // 先停用 provider
    mManager.setTestProviderEnabled(TEST_PROVIDER, false);
    
    AtomicBoolean enabledCallbackReceived = new AtomicBoolean(false);
    LocationListener listener = new LocationListener() {
        @Override
        public void onLocationChanged(Location location) {}
        
        @Override
        public void onProviderEnabled(String provider) {
            if (TEST_PROVIDER.equals(provider)) {
                enabledCallbackReceived.set(true);
            }
        }
        
        @Override
        public void onProviderDisabled(String provider) {}
    };
    
    mManager.requestLocationUpdates(TEST_PROVIDER, 1000, 0, listener);
    
    // 啟用 provider
    mManager.setTestProviderEnabled(TEST_PROVIDER, true);
    Thread.sleep(1000);
    
    assertThat(enabledCallbackReceived.get()).isTrue();  // ← 失敗
}
```

## 問題描述

當 provider 從停用變為啟用時，`LocationListener.onProviderEnabled()` 回調應該被呼叫，但實際上沒有收到。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationListener.java` — 回調介面定義
- `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java` — Provider 狀態管理

## 調試提示

1. Provider 狀態變更時，系統如何通知已註冊的監聽器？
2. `setTestProviderEnabled()` 如何影響 Provider 狀態？

## 任務

找出 provider enabled 回調無法觸發的 bug 並修復。
