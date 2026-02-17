# Q006 Answer: Sensor.getType() Returns Wrong Value

## 問題根因
在 `Sensor.java` 的建構函數中，從 native 資料設定欄位時，
`mType` 欄位被賦予了錯誤的參數。應該用 `type` 參數，
但誤用了 `stringType` 的 hashCode 或其他欄位。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// 錯誤的代碼
Sensor(String name, String vendor, int version, int handle, 
       int type, float maxRange, float resolution, float power,
       int minDelay, int fifoReservedEventCount, int fifoMaxEventCount,
       String stringType, String requiredPermission, int maxDelay,
       int flags) {
    mName = name;
    mVendor = vendor;
    mVersion = version;
    mHandle = handle;
    mType = maxDelay;  // BUG: 應該是 type
    // ...
}

// 正確的代碼
Sensor(...) {
    mName = name;
    mVendor = vendor;
    mVersion = version;
    mHandle = handle;
    mType = type;  // 正確
    // ...
}
```

## 相關知識
- Sensor 物件由 SystemSensorManager 從 native 層建構
- 類型常數定義：TYPE_ACCELEROMETER=1, TYPE_MAGNETIC_FIELD=2

## 難度說明
**Easy** - 類型值錯誤明確，檢查建構函數的賦值即可。
