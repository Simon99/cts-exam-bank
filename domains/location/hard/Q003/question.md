# Q003 [Hard]: GNSS Measurement Full Tracking Mode Ignored

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testGnssMeasurementsFullTracking
java.lang.AssertionError: 
Expected: Full tracking mode enabled
Actual: Standard mode (measurements only when location calculated)
    at android.location.cts.fine.LocationManagerFineTest.testGnssMeasurementsFullTracking(LocationManagerFineTest.java:978)
```

## 失敗的測試代碼片段

```java
@Test
public void testGnssMeasurementsFullTracking() throws Exception {
    // 請求完整追蹤模式（每秒都產生測量數據，不只是定位時）
    GnssMeasurementRequest request = new GnssMeasurementRequest.Builder()
        .setFullTracking(true)  // 啟用完整追蹤
        .build();
    
    assertThat(request.isFullTracking()).isTrue();
    
    GnssMeasurementsCapture capture = new GnssMeasurementsCapture(mContext);
    mManager.registerGnssMeasurementsCallback(request, DIRECT_EXECUTOR, capture);
    
    // 在 5 秒內應該收到多次測量數據（完整追蹤模式）
    List<GnssMeasurementsEvent> events = new ArrayList<>();
    for (int i = 0; i < 5; i++) {
        GnssMeasurementsEvent event = capture.getNextMeasurements(2000);
        if (event != null) {
            events.add(event);
        }
    }
    
    // 完整追蹤模式應該每秒都有數據，至少收到 4 次
    assertThat(events.size()).isAtLeast(4);  // ← 失敗：只收到 1-2 次
}
```

## 問題描述

`GnssMeasurementRequest.setFullTracking(true)` 應該啟用完整追蹤模式，讓 GNSS 硬體每秒都產生原始測量數據。但實際行為與標準模式相同（只在計算位置時才產生數據）。

## 相關源碼位置

呼叫鏈：
1. `frameworks/base/location/java/android/location/GnssMeasurementRequest.java` — Request 定義
2. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssManagerService.java` — 服務入口
3. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssMeasurementsProvider.java` — 請求合併
4. `frameworks/base/services/core/java/com/android/server/location/gnss/hal/GnssNative.java` — HAL 介面

## 調試提示

1. `fullTracking` 參數如何從 Request 傳遞到 HAL？
2. 多個 listeners 的請求如何合併？
3. `GnssNative.startMeasurementCollection()` 的參數是什麼？

## 任務

追蹤 fullTracking 參數的傳遞路徑，找出被忽略的原因。
