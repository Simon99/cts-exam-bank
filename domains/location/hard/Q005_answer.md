# Q005 答案 [Hard]：Mock Location Not Blocked for Non-Debug Apps

## Bug 位置（2 處）

### Bug 1: addTestProvider() 方法
權限檢查被移除：
- `enforceCallerIsMockLocationApp()` 被移除
- `hasMockLocationPermission()` 檢查被移除

### Bug 2: setTestProviderLocation() 方法
- `enforceCallerIsMockLocationApp()` 被移除

## 完整呼叫鏈

```
LocationManager.addTestProvider()
    → ILocationManager.addTestProvider()
        → LocationManagerService.addTestProvider() ← BUG 1
            → 應該: enforceCallerIsMockLocationApp()
            → 應該: hasMockLocationPermission()
            → LocationProviderManager.setMockProvider()

LocationManager.setTestProviderLocation()
    → ILocationManager.setTestProviderLocation()
        → LocationManagerService.setTestProviderLocation() ← BUG 2
            → 應該: enforceCallerIsMockLocationApp()
            → MockLocationProvider.setMockLocation()
```

## 修復方案

### 修復 Bug 1 (addTestProvider)
```java
@Override
public void addTestProvider(String provider, ProviderProperties properties,
        List<String> extraAttributionTags) {
    enforceCallerIsMockLocationApp();
    
    if (!hasMockLocationPermission()) {
        throw new SecurityException("Requires ACCESS_MOCK_LOCATION permission");
    }
    // ... rest of method
}
```

### 修復 Bug 2 (setTestProviderLocation)
```java
@Override
public void setTestProviderLocation(String provider, Location location) {
    Objects.requireNonNull(provider);
    enforceCallerIsMockLocationApp();
    // ... rest of method
}
```

## 安全性說明

### Mock Location 的兩層保護
1. **權限**：`ACCESS_MOCK_LOCATION` (只有系統簽名的 App 能持有)
2. **使用者設定**：開發者選項中的「選取模擬位置應用程式」

### enforceCallerIsMockLocationApp() 做什麼？
- 檢查呼叫者是否是使用者選定的 mock location app
- 透過 Settings.Secure.MOCK_LOCATION 比對

## 教學重點

1. **安全關鍵代碼**：權限檢查代碼不能隨意移除
2. **多層防護**：敏感功能通常有多重驗證
3. **Mock Location 風險**：可被用於欺騙位置相關的 App（如打卡、遊戲）
