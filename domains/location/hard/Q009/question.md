# Q009 [Hard]: NMEA Timestamp Incorrect After Timezone Change

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testNmeaTimestampTimezone
java.lang.AssertionError: 
Expected NMEA timestamp (UTC): 1703145600000 (2023-12-21 08:00:00 UTC)
Actual timestamp: 1703174400000 (2023-12-21 16:00:00 - shifted by timezone!)
Difference: 8 hours (matches local timezone offset)
    at android.location.cts.fine.LocationManagerFineTest.testNmeaTimestampTimezone(LocationManagerFineTest.java:1456)
```

## 失敗的測試代碼片段

```java
@Test
public void testNmeaTimestampTimezone() throws Exception {
    // 設定時區為 UTC+8
    TimeZone.setDefault(TimeZone.getTimeZone("Asia/Taipei"));
    
    AtomicLong receivedTimestamp = new AtomicLong(-1);
    OnNmeaMessageListener listener = new OnNmeaMessageListener() {
        @Override
        public void onNmeaMessage(String message, long timestamp) {
            // timestamp 應該是 UTC 時間（毫秒）
            receivedTimestamp.set(timestamp);
        }
    };
    
    mManager.addNmeaListener(DIRECT_EXECUTOR, listener);
    
    // 等待收到 NMEA 訊息
    Thread.sleep(5000);
    
    assertThat(receivedTimestamp.get()).isGreaterThan(0);
    
    // 驗證時間戳是 UTC（不受本地時區影響）
    // GNSS 時間 = GPS 週 + 週內毫秒，應轉換為 UTC
    long utcExpected = System.currentTimeMillis();  // 大約值
    long diff = Math.abs(receivedTimestamp.get() - utcExpected);
    
    // 允許 1 分鐘誤差
    assertThat(diff).isLessThan(60000);  // ← 失敗：差了 8 小時
}
```

## 問題描述

NMEA 訊息的時間戳應該是 UTC 時間，但實際返回的時間被本地時區偏移了。當時區為 UTC+8 時，時間戳錯誤地增加了 8 小時。

## 相關源碼位置

呼叫鏈：
1. `frameworks/base/location/java/android/location/OnNmeaMessageListener.java`
2. `frameworks/base/services/core/java/com/android/server/location/gnss/hal/GnssNative.java`
3. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssNmeaProvider.java`
4. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssLocationProvider.java`

## 調試提示

1. HAL 報告的 NMEA 時間戳是什麼格式？
2. 時間戳是如何從 HAL 傳遞到 listener 的？
3. 哪裡可能錯誤地套用了時區轉換？

## 任務

找出時區偏移被錯誤套用的位置。
