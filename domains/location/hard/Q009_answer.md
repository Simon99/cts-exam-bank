# Q009 答案 [Hard]：NMEA Timestamp Incorrect After Timezone Change

## Bug 位置（2 處）

### Bug 1: GnssNmeaProvider.onReportNmea()
錯誤地將時區偏移加到已經是 UTC 的時間戳上：
```java
// 錯誤：添加了時區偏移
long utcTimestamp = timestamp + TimeZone.getDefault().getRawOffset();
```

### Bug 2: GnssLocationProvider.convertGpsTimeToUtc()
GPS epoch 常量錯誤地加上了時區偏移：
```java
// 錯誤
long gpsEpochMs = 315964800000L + TimeZone.getDefault().getRawOffset();
```

## GPS 時間系統說明

- **GPS 時間**：GPS 衛星使用的時間系統，從 1980-01-06 開始
- **UTC**：協調世界時，全球統一的時間標準
- **NMEA 時間戳**：應該是 UTC 毫秒，不受本地時區影響

## 完整呼叫鏈

```
GNSS HAL (native)
    → GnssNative.reportNmea(timestamp)  // timestamp = UTC millis
        → GnssNmeaProvider.onReportNmea() ← BUG 1: +timezone
            → deliverToListeners()
                → OnNmeaMessageListener.onNmeaMessage(message, wrongTimestamp)

(另一路徑)
GnssNative.reportLocation()
    → GnssLocationProvider.convertGpsTimeToUtc() ← BUG 2: +timezone
```

## 修復方案

### 修復 Bug 1 (GnssNmeaProvider)
```java
@Override
public void onReportNmea(long timestamp) {
    // timestamp from HAL is already in UTC - don't add timezone!
    long utcTimestamp = timestamp;
    // ...
}
```

### 修復 Bug 2 (GnssLocationProvider)
```java
private long convertGpsTimeToUtc(long gpsWeek, long gpsTimeOfWeekMs) {
    long gpsEpochMs = 315964800000L;  // Fixed UTC value, no timezone
    long weekMs = gpsWeek * 7 * 24 * 60 * 60 * 1000L;
    return gpsEpochMs + weekMs + gpsTimeOfWeekMs;
}
```

## 教學重點

1. **UTC 是時區無關的**：UTC 時間戳不應該加上本地時區偏移
2. **GPS 時間到 UTC**：轉換只涉及 epoch 差異和閏秒，不涉及時區
3. **HAL 時間格式**：確認 HAL 傳遞的時間戳是什麼格式（通常是 UTC）
4. **時區 Bug 特徵**：誤差正好等於時區偏移量
