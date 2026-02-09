# Q007 [Hard]: GNSS Antenna Info Coordinates Swapped

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testGnssAntennaInfo
java.lang.AssertionError: 
Expected antenna offset X: 10.5mm, Y: -5.2mm, Z: 0.0mm
Actual: X: -5.2mm, Y: 10.5mm, Z: 0.0mm
    at android.location.cts.fine.LocationManagerFineTest.testGnssAntennaInfo(LocationManagerFineTest.java:1089)
```

## 失敗的測試代碼片段

```java
@Test
public void testGnssAntennaInfo() throws Exception {
    GnssAntennaInfoCapture capture = new GnssAntennaInfoCapture(mContext);
    mManager.registerGnssAntennaInfoCallback(DIRECT_EXECUTOR, capture);
    
    List<GnssAntennaInfo> antennaInfos = capture.getNextAntennaInfos(30000);
    assertThat(antennaInfos).isNotEmpty();
    
    GnssAntennaInfo info = antennaInfos.get(0);
    
    // 驗證天線偏移座標
    // X = 設備右方向（正值）
    // Y = 設備前方向（正值）
    // Z = 設備上方向（正值）
    GnssAntennaInfo.PhaseCenterOffset offset = info.getPhaseCenterOffset();
    
    // 預期 HAL 報告的值
    assertThat(offset.getXOffsetMm()).isWithin(0.1).of(10.5);  // ← 失敗
    assertThat(offset.getYOffsetMm()).isWithin(0.1).of(-5.2);  // ← 失敗
    assertThat(offset.getZOffsetMm()).isWithin(0.1).of(0.0);
}
```

## 問題描述

GNSS 天線資訊的 X 和 Y 座標被交換了。這會影響高精度定位應用（如測量、自動駕駛）的天線補償計算。

## 相關源碼位置

呼叫鏈：
1. `frameworks/base/location/java/android/location/GnssAntennaInfo.java` — 數據類
2. `frameworks/base/services/core/java/com/android/server/location/gnss/hal/GnssNative.java` — HAL 介面
3. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssAntennaInfoProvider.java` — Provider
4. `frameworks/base/services/core/java/com/android/server/location/gnss/GnssManagerService.java` — 服務

## 調試提示

1. 座標是如何從 HAL 傳遞到 GnssAntennaInfo 的？
2. 哪裡進行了座標轉換？
3. Android Coordinate System 的定義是什麼？

## 任務

追蹤座標數據的流向，找出 X/Y 被交換的位置。
