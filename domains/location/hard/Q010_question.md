# Q010 [Hard]: GnssMeasurementRequest Parcelable 序列化/反序列化不一致

## CTS 測試失敗現象

```
FAIL: android.location.cts.GnssMeasurementRequestTest#testParcelRoundTrip
java.lang.AssertionError: 
Expected: GnssMeasurementRequest[@1000ms, FullTracking, CorrelationVectorOutputs]
Actual: GnssMeasurementRequest[@1000ms, CorrelationVectorOutputs]
fullTracking mismatch: expected true, was false

    at android.location.cts.GnssMeasurementRequestTest.testParcelRoundTrip(GnssMeasurementRequestTest.java:78)

Additional failures observed:
- testAddMeasurementListenerWithFullTracking: Permission check bypassed
- testMeasurementRequestPassive: PASSIVE_INTERVAL check failed
```

## 失敗的測試代碼片段

```java
@Test
public void testParcelRoundTrip() {
    GnssMeasurementRequest original = new GnssMeasurementRequest.Builder()
            .setIntervalMillis(1000)
            .setFullTracking(true)
            .setCorrelationVectorOutputsEnabled(true)
            .build();
    
    // 寫入 Parcel
    Parcel parcel = Parcel.obtain();
    original.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    // 從 Parcel 讀取
    GnssMeasurementRequest recreated = GnssMeasurementRequest.CREATOR.createFromParcel(parcel);
    parcel.recycle();
    
    // 驗證所有欄位
    assertEquals(original.getIntervalMillis(), recreated.getIntervalMillis());
    assertEquals(original.isFullTracking(), recreated.isFullTracking());  // ← 失敗！
    assertEquals(original.isCorrelationVectorOutputsEnabled(), 
                 recreated.isCorrelationVectorOutputsEnabled());
    
    assertEquals(original, recreated);  // ← 也失敗
}
```

## 問題描述

這是一個涉及多個文件的序列化問題鏈：
1. `GnssMeasurementRequest` 的 Parcelable 實現有欄位順序錯誤
2. `GnssMeasurementsProvider` 使用了錯誤的方法來判斷 request 類型
3. `GnssManagerService` 的權限檢查使用了錯誤的 getter

由於 `fullTracking` 和 `correlationVectorOutputsEnabled` 值互換，會導致：
- 權限檢查被繞過
- PASSIVE 請求判斷錯誤
- HAL 層收到錯誤的設定

## 相關源碼位置

```
frameworks/base/location/java/android/location/GnssMeasurementRequest.java
frameworks/base/services/core/java/com/android/server/location/gnss/GnssMeasurementsProvider.java
frameworks/base/services/core/java/com/android/server/location/gnss/GnssManagerService.java
```

## 呼叫鏈

```
App 端:
  GnssMeasurementRequest.writeToParcel()
    ↓ Binder IPC
Server 端:
  GnssManagerService.addGnssMeasurementsListener()
    ↓ 檢查 request.isCorrelationVectorOutputsEnabled() 需要額外權限
  GnssMeasurementsProvider.addListener()
    ↓ registerWithService()
    ↓ 判斷是否為 PASSIVE_INTERVAL
  GnssNative.startMeasurementCollection(fullTracking, correlationVector, interval)
```

## Parcelable 實現模式

```java
// 寫入順序
@Override
public void writeToParcel(Parcel parcel, int flags) {
    parcel.writeBoolean(field1);
    parcel.writeBoolean(field2);
    parcel.writeInt(field3);
    // ...
}

// 讀取順序必須完全一致
public static final Creator<T> CREATOR = new Creator<T>() {
    @Override
    public T createFromParcel(Parcel parcel) {
        boolean field1 = parcel.readBoolean();
        boolean field2 = parcel.readBoolean();
        int field3 = parcel.readInt();
        // ...
    }
};
```

## 調試提示

1. 比較 `writeToParcel()` 中的寫入順序
2. 比較 `createFromParcel()` 中的讀取順序
3. 欄位順序不匹配會導致資料錯位
4. 追蹤 request 如何在 Service 層被使用
5. 檢查哪些地方使用 `isFullTracking()` 和 `isCorrelationVectorOutputsEnabled()`

## 任務

找出涉及 `GnssMeasurementRequest` 序列化和使用的多處錯誤（共 3 個文件）。
