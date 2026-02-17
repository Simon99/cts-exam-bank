# Q002: GnssStatus.getSvid() Returns Wrong Satellite ID

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.GnssStatusTest#testGnssStatusSvid
java.lang.AssertionError: 
Expected SVID for GPS satellite: 12
Actual: 0
    at android.location.cts.none.GnssStatusTest.testGnssStatusSvid(GnssStatusTest.java:87)
```

## 失敗的測試代碼片段

```java
@Test
public void testGnssStatusSvid() {
    // 建立測試用的 GnssStatus，包含一個 GPS 衛星 (SVID=12)
    int[] svidWithFlags = new int[] {
        (12 << 12) | (GnssStatus.CONSTELLATION_GPS << 8) | FLAGS_USED_IN_FIX
    };
    float[] cn0s = new float[] { 30.0f };
    float[] elevations = new float[] { 45.0f };
    float[] azimuths = new float[] { 180.0f };
    float[] carrierFreqs = new float[] { 1575420000f };
    float[] basebandCn0s = new float[] { 28.0f };
    
    GnssStatus status = GnssStatus.wrap(1, svidWithFlags, cn0s, 
            elevations, azimuths, carrierFreqs, basebandCn0s);
    
    assertThat(status.getSvid(0)).isEqualTo(12);  // ← 失敗：返回 0
}
```

## 問題描述

`GnssStatus.getSvid()` 方法應該返回正確的衛星 ID (SVID)，但實際返回 0。SVID 是從 `svidWithFlags` 數組中提取的，編碼方式是 `(svid << 12) | (constellation << 8) | flags`。

## 相關源碼位置

- `frameworks/base/location/java/android/location/GnssStatus.java` — 客戶端數據類
- `frameworks/base/services/core/java/com/android/server/location/gnss/GnssStatusProvider.java` — 伺服器端 provider

## 調試提示

1. `GnssStatus.getSvid()` 如何從 `svidWithFlags` 提取 SVID？
2. 位移操作是否正確？ (SVID_SHIFT_WIDTH = 12)

## 任務

找出 SVID 提取邏輯的 bug 並修復。
