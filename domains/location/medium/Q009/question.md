# Q009: LocationManager.getProviders() Returns Incomplete List

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testGetProviders
java.lang.AssertionError: 
Expected providers list to contain: [gps, network, fused, passive, test_provider]
Actual: [test_provider]
    at android.location.cts.fine.LocationManagerFineTest.testGetProviders(LocationManagerFineTest.java:234)
```

## 失敗的測試代碼片段

```java
@Test
public void testGetProviders() {
    // 獲取所有已啟用的 provider
    List<String> enabledProviders = mManager.getProviders(true);
    
    // 確認包含預期的 provider
    assertThat(enabledProviders).contains(GPS_PROVIDER);
    assertThat(enabledProviders).contains(NETWORK_PROVIDER);  // ← 失敗
    assertThat(enabledProviders).contains(FUSED_PROVIDER);
    assertThat(enabledProviders).contains(PASSIVE_PROVIDER);
    assertThat(enabledProviders).contains(TEST_PROVIDER);
}
```

## 問題描述

`getProviders(true)` 應該返回所有已啟用的 location provider，但只返回了 `test_provider`，遺漏了其他系統 provider。

## 相關源碼位置

- `frameworks/base/location/java/android/location/LocationManager.java` — getProviders API
- `frameworks/base/services/core/java/com/android/server/location/LocationManagerService.java` — Provider 列表管理

## 調試提示

1. `getProviders(enabledOnly)` 的過濾邏輯在哪裡？
2. 如何判斷一個 provider 是否 "enabled"？

## 任務

找出 provider 列表不完整的 bug 並修復。
