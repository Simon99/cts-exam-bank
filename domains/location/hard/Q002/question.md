# Q002 [Hard]: GNSS First Fix Time Not Reported

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testGnssStatusCallbackTtff
java.util.concurrent.TimeoutException: onFirstFix callback not received within 60 seconds
    at android.location.cts.fine.LocationManagerFineTest.testGnssStatusCallbackTtff(LocationManagerFineTest.java:823)
```

## 失敗的測試代碼片段

```java
@Test
public void testGnssStatusCallbackTtff() throws Exception {
    CountDownLatch ttffLatch = new CountDownLatch(1);
    AtomicInteger ttffMs = new AtomicInteger(-1);
    
    GnssStatus.Callback callback = new GnssStatus.Callback() {
        @Override
        public void onStarted() {
            Log.d(TAG, "GNSS started");
        }
        
        @Override
        public void onFirstFix(int ttffMillis) {
            Log.d(TAG, "First fix: " + ttffMillis + "ms");
            ttffMs.set(ttffMillis);
            ttffLatch.countDown();
        }
        
        @Override
        public void onSatelliteStatusChanged(GnssStatus status) {
            // 有收到衛星狀態更新
        }
    };
    
    mManager.registerGnssStatusCallback(DIRECT_EXECUTOR, callback);
    
    // 等待 first fix
    assertTrue("onFirstFix not called", ttffLatch.await(60, TimeUnit.SECONDS));  // ← 超時
    assertThat(ttffMs.get()).isGreaterThan(0);
}
```

## 問題描述

GNSS 引擎成功獲得定位（可以看到位置更新和衛星狀態），但 `onFirstFix()` 回調從未被觸發。TTFF (Time To First Fix) 是從 GNSS 啟動到獲得第一個有效定位的時間。

## 相關源碼位置

呼叫鏈（HAL 到 Framework）：
1. `frameworks/base/services/core/java/com/android/server/location/gnss/hal/GnssNative.java` — HAL 介面
2. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssLocationProvider.java` — 定位 Provider
3. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssStatusProvider.java` — 狀態 Provider

## 調試提示

1. HAL 如何通知 first fix 事件？
2. first fix 事件從 HAL 到 GnssStatus.Callback 的路徑是什麼？
3. 哪個模組負責計算 TTFF 並通知 listeners？

## 任務

追蹤 HAL callback 鏈，找出 onFirstFix 回調失效的原因（可能涉及多處 bug）。
