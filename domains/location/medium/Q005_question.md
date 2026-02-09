# Q005: GnssMeasurementsEvent Callback Not Invoked

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testRegisterGnssMeasurementsCallback
java.util.concurrent.TimeoutException: Callback was not invoked within 30 seconds
    at android.location.cts.fine.LocationManagerFineTest.testRegisterGnssMeasurementsCallback(LocationManagerFineTest.java:892)
```

## 失敗的測試代碼片段

```java
@Test
public void testRegisterGnssMeasurementsCallback() throws Exception {
    GnssMeasurementsCapture capture = new GnssMeasurementsCapture(mContext);
    GnssMeasurementRequest request = new GnssMeasurementRequest.Builder()
        .setFullTracking(true)
        .build();
    
    mManager.registerGnssMeasurementsCallback(
        request, DIRECT_EXECUTOR, capture);
    
    try {
        // 等待收到測量數據
        GnssMeasurementsEvent event = capture.getNextMeasurements(30000);
        assertThat(event).isNotNull();  // ← 超時，未收到數據
        assertThat(event.getMeasurements()).isNotEmpty();
    } finally {
        mManager.unregisterGnssMeasurementsCallback(capture);
    }
}
```

## 問題描述

註冊 GNSS 測量回調後，即使 GNSS 硬體正常運作並產生測量數據，回調也不會被觸發。Logger 顯示 HAL 層有數據產生。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationManager.java` — 客戶端註冊 API
- `frameworks/base/services/core/java/com/android/server/location/gnss/GnssMeasurementsProvider.java` — 測量數據 Provider

## 調試提示

1. 監聽器是否正確註冊到服務？
2. HAL 回調是否正確傳遞到 listeners？

## 任務

找出回調無法觸發的 bug 並修復。
