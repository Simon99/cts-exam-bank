# Q005 [Hard]: Mock Location Not Blocked for Non-Debug Apps

## CTS 測試失敗現象

```
FAIL: android.location.cts.fine.LocationManagerFineTest#testMockLocationBlocking
java.lang.AssertionError: 
Expected: SecurityException when non-debug app sets mock location
Actual: No exception thrown, mock location was accepted
    at android.location.cts.fine.LocationManagerFineTest.testMockLocationBlocking(LocationManagerFineTest.java:1123)
```

## 失敗的測試代碼片段

```java
@Test
public void testMockLocationBlocking() throws Exception {
    // 這個測試以非 debug app 身份執行
    // 設定 mock location 應該拋出 SecurityException
    
    try {
        mManager.addTestProvider(TEST_PROVIDER, 
            new ProviderProperties.Builder().build());
        fail("Expected SecurityException");  // ← 沒有拋出例外
    } catch (SecurityException e) {
        // 預期行為
    }
    
    // 即使 test provider 存在，設定 location 也應該失敗
    try {
        Location mockLoc = createLocation(GPS_PROVIDER, 37.0, -122.0);
        mockLoc.setIsFromMockProvider(true);
        mManager.setTestProviderLocation(GPS_PROVIDER, mockLoc);
        fail("Expected SecurityException");
    } catch (SecurityException e) {
        // 預期行為
    }
}
```

## 問題描述

只有具備 `android.permission.ACCESS_MOCK_LOCATION` 權限且在開發者選項中被選為「模擬位置應用程式」的 App 才能設定 mock location。但目前任何 App 都可以設定，這是嚴重的安全問題。

## 相關源碼位置

呼叫鏈：
1. `frameworks/base/location/java/android/location/LocationManager.java`
2. `frameworks/base/services/core/java/com/android/server/location/LocationManagerService.java`
3. `frameworks/base/services/core/java/com/android/server/location/provider/MockLocationProvider.java`
4. `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`

## 調試提示

1. Mock location 權限檢查在哪裡進行？
2. `addTestProvider` 和 `setTestProviderLocation` 的權限驗證流程？
3. 如何判斷一個 App 是否被設為「模擬位置應用程式」？

## 任務

追蹤權限檢查邏輯，找出安全驗證被繞過的原因。
