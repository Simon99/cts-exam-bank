# Q008 答案：幀持續時間數值錯誤

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `CaptureResult.java`：`get()` 有 log 顯示 frame duration
2. **根因檔案** `CameraMetadataNative.java`：對 SENSOR_FRAME_DURATION 錯誤乘以 3

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/CaptureResult.java`

```java
@Nullable
public <T> T get(Key<T> key) {
    T value = mResults.get(key);  // 呼叫 CameraMetadataNative.get()
    
    // 線索 log：顯示 frame duration 值
    if (VERBOSE && "android.sensor.frameDuration".equals(key.getName())) {
        Log.v(TAG, "Frame duration: " + value + " ns (raw from HAL)");
    }
    
    return value;
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
@SuppressWarnings("unchecked")
public <T> T get(CaptureResult.Key<T> key) {
    // BUG: 對 SENSOR_FRAME_DURATION 錯誤地乘以 3
    if ("android.sensor.frameDuration".equals(key.getName())) {
        Long rawValue = (Long) get(key.getNativeKey());
        return (T) (rawValue != null ? Long.valueOf(rawValue * 3) : null);
    }
    
    return get(key.getNativeKey());
}
```

## 呼叫鏈

```
App 呼叫 CaptureResult.get(SENSOR_FRAME_DURATION)
    ↓
CaptureResult.get(key)  ← 線索 log 顯示值
    ↓ mResults.get(key)
CameraMetadataNative.get(CaptureResult.Key)  ← BUG：乘以 3
    ↓ get(key.getNativeKey())
native 層取值（正確值）
```

## 追蹤方法

1. 觀察 CTS 測試：SENSOR_FRAME_DURATION 值是預期的 3 倍
2. 在 `CaptureResult.get()` 看到 "raw from HAL" 的 log
3. 懷疑值在 metadata 層被修改
4. 追蹤到 `CameraMetadataNative.get()` 發現乘以 3

## 修復方法

**文件 2（必須修復）：**
```java
public <T> T get(CaptureResult.Key<T> key) {
    // 移除錯誤的 frame duration 處理
    // SENSOR_FRAME_DURATION 單位是 nanoseconds，不需要轉換
    
    return get(key.getNativeKey());
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest CaptureResultTest#testCaptureResultGet`
4. 測試應該通過

## 學習重點
- SENSOR_FRAME_DURATION 單位是 nanoseconds
- 這個值影響 FPS 計算：FPS = 1e9 / frameDuration
- metadata 層不應該修改 HAL 回報的原始值
