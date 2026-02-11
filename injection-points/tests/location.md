# location 注入點分布列表

**CTS 路徑**: `cts/tests/location/`  
**更新時間**: 2026-02-14  
**版本**: v1.0.0

---

## 概覽

- **總注入點數**: 47
- **按難度分布**: Easy(18) / Medium(19) / Hard(10)
- **涵蓋測試類別**:
  - LocationManagerFineTest
  - LocationTest
  - GeofencingTest
  - GnssStatusTest
  - GnssMeasurementTest
  - GnssClockTest
  - GeocoderTest
  - LocationRequestTest
  - CriteriaTest

---

## 對應 AOSP 源碼路徑

### Client-side APIs (frameworks/base)
- `frameworks/base/core/java/android/location/Location.java`
- `frameworks/base/location/java/android/location/LocationManager.java`
- `frameworks/base/location/java/android/location/LocationRequest.java`
- `frameworks/base/location/java/android/location/Geocoder.java`
- `frameworks/base/location/java/android/location/GnssStatus.java`
- `frameworks/base/location/java/android/location/GnssMeasurement.java`
- `frameworks/base/location/java/android/location/GnssClock.java`
- `frameworks/base/location/java/android/location/Criteria.java`
- `frameworks/base/location/java/android/location/Address.java`

### Server-side Implementation (frameworks/base/services)
- `frameworks/base/services/core/java/com/android/server/location/LocationManagerService.java`
- `frameworks/base/services/core/java/com/android/server/location/provider/LocationProviderManager.java`
- `frameworks/base/services/core/java/com/android/server/location/geofence/GeofenceManager.java`
- `frameworks/base/services/core/java/com/android/server/location/fudger/LocationFudger.java`
- `frameworks/base/services/core/java/com/android/server/location/gnss/GnssLocationProvider.java`
- `frameworks/base/services/core/java/com/android/server/location/gnss/GnssManagerService.java`
- `frameworks/base/services/core/java/com/android/server/location/LocationPermissions.java`

---

## 注入點清單

### 1. Location 資料類別 (Location.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-001 | Location.java | distanceTo() | 201-217 | CALC | Easy | LocationTest#testDistanceTo |
| LOC-002 | Location.java | bearingTo() | 219-235 | CALC | Easy | LocationTest#testBearingTo |
| LOC-003 | Location.java | computeDistanceAndBearing() | (static) | CALC | Medium | LocationTest#testDistanceBetween |
| LOC-004 | Location.java | setBearing() | 550-560 | BOUND, CALC | Easy | LocationTest#testValues |
| LOC-005 | Location.java | setLatitude() / setLongitude() | 380-400 | BOUND | Easy | LocationTest#testValues |
| LOC-006 | Location.java | getElapsedRealtimeAgeMillis() | 320-325 | CALC | Easy | LocationTest#testElapsedRealtimeAge |
| LOC-007 | Location.java | isComplete() | 830-833 | COND | Easy | LocationTest#testIsComplete |
| LOC-008 | Location.java | equals() | 840-880 | COND | Medium | LocationTest#testEquals |
| LOC-009 | Location.java | hasAccuracy() / hasAltitude() | (field masks) | COND | Easy | LocationTest#testHasFields |
| LOC-010 | Location.java | convert() (coordinate formatting) | 1050-1150 | STR, CALC | Medium | LocationTest#testConvert_CoordinateToRepresentation |
| LOC-011 | Location.java | convert() (string to coordinate) | 1160-1250 | STR, ERR | Medium | LocationTest#testConvert_RepresentationToCoordinate |

### 2. LocationManager 服務 (LocationManagerService.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-012 | LocationManagerService.java | getProviders() | 700-720 | COND | Easy | LocationManagerFineTest#testGetProviders |
| LOC-013 | LocationManagerService.java | getBestProvider() | 725-745 | COND | Medium | LocationManagerFineTest#testGetBestProvider |
| LOC-014 | LocationManagerService.java | isProviderEnabled() | 570-580 | COND, STATE | Easy | LocationManagerFineTest#testIsProviderEnabled |
| LOC-015 | LocationManagerService.java | validateLocationRequest() | 850-920 | BOUND, ERR | Medium | LocationManagerFineTest#testRequestLocationUpdates |
| LOC-016 | LocationManagerService.java | registerLocationListener() | 780-815 | ERR, STATE | Medium | LocationManagerFineTest#testRequestLocationUpdates |
| LOC-017 | LocationManagerService.java | getCurrentLocation() | 760-778 | STATE, ERR | Medium | LocationManagerFineTest#testGetCurrentLocation |
| LOC-018 | LocationManagerService.java | getLastKnownLocation() | (multiple) | COND, STATE | Medium | LocationManagerFineTest#testGetLastKnownLocation |

### 3. LocationProviderManager (LocationProviderManager.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-019 | LocationProviderManager.java | registerLocationRequest() | 600-650 | STATE, ERR | Hard | LocationManagerFineTest#testRequestLocationUpdates |
| LOC-020 | LocationProviderManager.java | onLocationChanged() | (registration) | STATE, SYNC | Hard | LocationManagerFineTest#testLocationUpdates |
| LOC-021 | LocationProviderManager.java | deliverOnLocationChanged() | 250-280 | ERR, SYNC | Hard | LocationManagerFineTest#testLocationCallback |
| LOC-022 | LocationProviderManager.java | isEnabled() | (multiple) | COND, STATE | Easy | LocationManagerFineTest#testIsProviderEnabled |
| LOC-023 | LocationProviderManager.java | MIN_COARSE_INTERVAL_MS | (constant) | BOUND | Medium | LocationManagerFineTest#testCoarseLocationInterval |

### 4. Geofence 管理 (GeofenceManager.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-024 | GeofenceManager.java | onLocationChanged() | 230-260 | CALC, COND | Medium | GeofencingTest#testAddProximityAlert |
| LOC-025 | GeofenceManager.java | getDistanceToBoundary() | 220-228 | CALC | Easy | GeofencingTest#testAddProximityAlert |
| LOC-026 | GeofenceManager.java | STATE_INSIDE / STATE_OUTSIDE | (state machine) | STATE | Medium | GeofencingTest#testAddProximityAlert |
| LOC-027 | GeofenceManager.java | mGeofence.getRadius() comparison | 247 | CALC, BOUND | Medium | GeofencingTest#testGeofenceRadius |
| LOC-028 | GeofenceManager.java | isExpired() check | 233 | COND | Easy | GeofencingTest#testGeofenceExpiration |
| LOC-029 | GeofenceManager.java | sendIntent() | 262-275 | ERR, RES | Medium | GeofencingTest#testProximityIntent |

### 5. LocationFudger (LocationFudger.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-030 | LocationFudger.java | createCoarse() | 115-165 | CALC | Hard | LocationManagerFineTest#testCoarseLocation |
| LOC-031 | LocationFudger.java | updateOffsets() | 195-210 | CALC, STATE | Hard | LocationManagerFineTest#testCoarseLocationAccuracy |
| LOC-032 | LocationFudger.java | metersToDegreesLatitude() | 220-225 | CALC | Easy | LocationManagerFineTest#testCoarseLocation |
| LOC-033 | LocationFudger.java | metersToDegreesLongitude() | 227-232 | CALC | Medium | LocationManagerFineTest#testCoarseLocation |
| LOC-034 | LocationFudger.java | wrapLatitude() / wrapLongitude() | 235-250 | BOUND, CALC | Easy | LocationManagerFineTest#testCoarseLocation |
| LOC-035 | LocationFudger.java | MIN_ACCURACY_M | (constant) | BOUND | Easy | LocationManagerFineTest#testMinimumAccuracy |

### 6. LocationRequest (LocationRequest.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-036 | LocationRequest.java | Builder.setIntervalMillis() | (builder) | BOUND | Easy | LocationRequestTest#testIntervalMillis |
| LOC-037 | LocationRequest.java | Builder.setMinUpdateIntervalMillis() | (builder) | BOUND, CALC | Medium | LocationRequestTest#testMinUpdateInterval |
| LOC-038 | LocationRequest.java | Builder.setQuality() | (builder) | BOUND | Easy | LocationRequestTest#testQuality |
| LOC-039 | LocationRequest.java | PASSIVE_INTERVAL handling | (constant) | COND | Medium | LocationRequestTest#testPassiveInterval |
| LOC-040 | LocationRequest.java | equals() / hashCode() | (multiple) | COND | Medium | LocationRequestTest#testEquals |

### 7. GNSS 相關 (GnssLocationProvider.java, GnssStatus.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-041 | GnssLocationProvider.java | LocationExtras.set() | 175-185 | STATE | Hard | GnssClockTest, GnssMeasurementTest |
| LOC-042 | GnssLocationProvider.java | handleReportLocation() | (multiple) | STATE, ERR | Hard | LocationManagerFineTest#testGpsLocation |
| LOC-043 | GnssStatus.java | Builder.addSatellite() | (builder) | BOUND | Easy | GnssStatusTest#testGetValues |
| LOC-044 | GnssStatus.java | getSatelliteCount() | (getter) | BOUND | Easy | GnssStatusTest#testBuilder_ClearSatellites |
| LOC-045 | GnssStatus.java | usedInFix() | (getter) | COND | Easy | GnssStatusTest#testGetValues |

### 8. 權限檢查 (LocationPermissions.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| LOC-046 | LocationPermissions.java | enforceLocationPermission() | (multiple) | COND, ERR | Hard | NoLocationPermissionTest |
| LOC-047 | LocationPermissions.java | getPermissionLevel() | (multiple) | COND | Hard | LocationManagerFineTest#testPermissions |

---

## 難度分布統計

| 難度 | 數量 | 百分比 |
|------|------|--------|
| Easy | 18 | 38.3% |
| Medium | 19 | 40.4% |
| Hard | 10 | 21.3% |
| **總計** | **47** | 100% |

---

## 注入類型分布統計

| 類型 | 說明 | 出現次數 |
|------|------|----------|
| CALC | 數值計算（距離、角度、座標轉換） | 18 |
| COND | 條件判斷 | 16 |
| BOUND | 邊界檢查 | 11 |
| STATE | 狀態轉換 | 11 |
| ERR | 錯誤處理 | 9 |
| STR | 字串處理 | 2 |
| SYNC | 同步問題 | 2 |
| RES | 資源管理 | 1 |

---

## 推薦優先注入點

### Easy 入門題（建議先從這些開始）

1. **LOC-001** (distanceTo) - 距離計算邏輯簡單明確
2. **LOC-004** (setBearing) - 邊界值處理（0-360度）
3. **LOC-007** (isComplete) - 簡單的條件組合
4. **LOC-035** (MIN_ACCURACY_M) - 常數值修改

### Medium 進階題

1. **LOC-024** (Geofence onLocationChanged) - 狀態機邏輯
2. **LOC-010** (Location.convert) - 座標格式轉換
3. **LOC-013** (getBestProvider) - Provider 選擇邏輯
4. **LOC-033** (metersToDegreesLongitude) - 經度計算需考慮緯度

### Hard 挑戰題

1. **LOC-030** (LocationFudger.createCoarse) - 複雜的位置模糊化算法
2. **LOC-019** (registerLocationRequest) - 跨元件狀態管理
3. **LOC-046** (enforceLocationPermission) - 權限驗證邏輯

---

## 備註

1. **Location.java** 位於 `core/java` 而非 `location/java`，注意路徑
2. **Geofence** 測試需要真實設備執行，模擬器可能不支援
3. **GNSS** 相關測試需要 GPS 硬體支援
4. 許多注入點涉及 **浮點數計算**，需注意精度問題
5. **LocationFudger** 涉及隱私保護，注入需謹慎設計

---

**文件版本**: v1.0.0  
**更新時間**: 2026-02-14
