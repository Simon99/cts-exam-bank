# Q010: GnssStatus.usedInFix() Always Returns False

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.GnssStatusTest#testUsedInFix
java.lang.AssertionError: 
Expected at least one satellite used in fix
Actual: All satellites report usedInFix = false
    at android.location.cts.none.GnssStatusTest.testUsedInFix(GnssStatusTest.java:112)
```

## 失敗的測試代碼片段

```java
@Test
public void testUsedInFix() {
    // 建立測試用的 GnssStatus，包含 3 顆衛星，其中 2 顆用於定位
    int flagUsedInFix = 0x04;  // SVID_FLAGS_USED_IN_FIX
    int[] svidWithFlags = new int[] {
        (10 << 12) | (CONSTELLATION_GPS << 8) | flagUsedInFix,  // used
        (15 << 12) | (CONSTELLATION_GPS << 8) | flagUsedInFix,  // used
        (20 << 12) | (CONSTELLATION_GPS << 8) | 0               // not used
    };
    // ... other arrays ...
    
    GnssStatus status = GnssStatus.wrap(3, svidWithFlags, cn0s, 
            elevations, azimuths, carrierFreqs, basebandCn0s);
    
    // 至少應該有一顆衛星用於定位
    boolean anyUsedInFix = false;
    for (int i = 0; i < status.getSatelliteCount(); i++) {
        if (status.usedInFix(i)) {
            anyUsedInFix = true;
            break;
        }
    }
    assertThat(anyUsedInFix).isTrue();  // ← 失敗
}
```

## 問題描述

即使衛星的 `SVID_FLAGS_USED_IN_FIX` 標誌已設定，`usedInFix()` 方法仍然返回 false。

## 相關源碼位置

- `frameworks/base/location/java/android/location/GnssStatus.java` — usedInFix() 方法
- `frameworks/base/services/core/java/com/android/server/location/gnss/GnssStatusProvider.java` — 標誌處理

## 調試提示

1. `SVID_FLAGS_USED_IN_FIX` 的值是什麼？(0x04 = 1 << 2)
2. 標誌是如何從 HAL 傳遞到 GnssStatus 的？

## 任務

找出 usedInFix 標誌無法正確傳遞的 bug 並修復。
