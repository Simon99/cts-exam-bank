# Q010 答案：GnssMeasurementRequest Parcelable 序列化/反序列化不一致

## 問題根因

這是一個涉及三個文件的連鎖錯誤：

1. **GnssMeasurementRequest.java** - Parcelable 讀取順序錯誤
2. **GnssMeasurementsProvider.java** - 使用錯誤的方法判斷 PASSIVE 請求
3. **GnssManagerService.java** - 權限檢查使用錯誤的 getter

## Bug 位置

### Bug 1 - GnssMeasurementRequest.java (約 118 行)

```java
public GnssMeasurementRequest createFromParcel(@NonNull Parcel parcel) {
    return new GnssMeasurementRequest(
            // BUG: 參數順序互換
            /* correlationVectorOutputsEnabled= */ parcel.readBoolean(),  // 應該是 fullTracking
            /* fullTracking= */ parcel.readBoolean(),  // 應該是 correlationVector
            /* intervalMillis= */ parcel.readInt(),
            /* workSource= */ parcel.readTypedObject(WorkSource.CREATOR));
}
```

**修復**：恢復正確的讀取順序
```java
return new GnssMeasurementRequest(
        /* fullTracking= */ parcel.readBoolean(),
        /* correlationVectorOutputsEnabled= */ parcel.readBoolean(),
        /* intervalMillis= */ parcel.readInt(),
        /* workSource= */ parcel.readTypedObject(WorkSource.CREATOR));
```

### Bug 2 - GnssMeasurementsProvider.java (約 131 行)

```java
protected boolean registerWithService(GnssMeasurementRequest request, ...) {
    // BUG: 錯誤地檢查 fullTracking 而非 intervalMillis
    if (request.isFullTracking()) {  // 應該是 getIntervalMillis() == PASSIVE_INTERVAL
        return true;
    }
    // BUG: 傳給 HAL 的第一個參數用錯
    if (mGnssNative.startMeasurementCollection(
            request.isCorrelationVectorOutputsEnabled(),  // 應該是 isFullTracking()
            request.isCorrelationVectorOutputsEnabled(),
            request.getIntervalMillis())) {
```

**修復**：
```java
if (request.getIntervalMillis() == GnssMeasurementRequest.PASSIVE_INTERVAL) {
    return true;
}
if (mGnssNative.startMeasurementCollection(
        request.isFullTracking(),
        request.isCorrelationVectorOutputsEnabled(),
        request.getIntervalMillis())) {
```

### Bug 3 - GnssManagerService.java (約 211 行)

```java
public void addGnssMeasurementsListener(GnssMeasurementRequest request, ...) {
    mContext.enforceCallingOrSelfPermission(ACCESS_FINE_LOCATION, null);
    // BUG: 使用錯誤的方法檢查權限
    if (request.isFullTracking()) {  // 應該是 isCorrelationVectorOutputsEnabled()
        mContext.enforceCallingOrSelfPermission(LOCATION_HARDWARE, null);
    }
```

**修復**：
```java
if (request.isCorrelationVectorOutputsEnabled()) {
    mContext.enforceCallingOrSelfPermission(LOCATION_HARDWARE, null);
}
```

## 呼叫鏈

```
LocationManager.registerGnssMeasurementsCallback(request, callback)
    ↓
ILocationManager.addGnssMeasurementsListener(request, listener)
    ↓ request 跨 Binder IPC（此時 Parcelable 序列化）
GnssManagerService.addGnssMeasurementsListener()   ← Bug 3：權限檢查用錯
    ↓
GnssMeasurementsProvider.addListener(request, ...)
    ↓ registerWithService()                         ← Bug 2：PASSIVE 判斷錯誤
    ↓
GnssNative.startMeasurementCollection(...)          ← Bug 2：參數傳錯
```

## 錯誤影響分析

| 欄位組合 | 預期行為 | 實際行為（有 bug）|
|---------|---------|------------------|
| fullTracking=true, correlation=false | 需要普通權限，啟用 full tracking | 不檢查權限，correlation 被啟用 |
| fullTracking=false, correlation=true | 需要 LOCATION_HARDWARE | 不檢查權限，被當作 PASSIVE |
| fullTracking=true, correlation=true | 兩者都啟用，需要額外權限 | 權限檢查錯誤，設定錯誤 |

## 驗證方法

1. 還原所有三個 patch
2. 重新編譯 framework 和 services
3. 執行測試：
   ```
   atest android.location.cts.GnssMeasurementRequestTest
   ```

## 學習重點

- Parcelable 的讀寫順序必須完全一致
- 當 Parcelable 欄位被錯誤反序列化時，影響會擴散到整個使用鏈
- 需要追蹤資料從客戶端到服務端的完整流程
- boolean 欄位互換不會造成 crash，但會導致語義錯誤
