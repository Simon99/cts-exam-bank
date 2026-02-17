# Q006 答案：對焦距離數值錯誤

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `CaptureResult.java`：`get()` 方法有轉換 log
2. **根因檔案** `CameraMetadataNative.java`：對 LENS_FOCUS_DISTANCE 錯誤乘以 10

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/CaptureResult.java`

```java
@Nullable
public <T> T get(Key<T> key) {
    T value = mResults.get(key);  // 呼叫 CameraMetadataNative.get()
    
    // 線索 log：提到 focus distance 轉換
    if (VERBOSE && "android.lens.focusDistance".equals(key.getName())) {
        Log.v(TAG, "Converting focus distance from diopters, raw=" + value);
    }
    
    return value;
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
@SuppressWarnings("unchecked")
public <T> T get(CaptureResult.Key<T> key) {
    // BUG: 對 LENS_FOCUS_DISTANCE 錯誤地乘以 10
    if ("android.lens.focusDistance".equals(key.getName())) {
        Float rawValue = (Float) get(key.getNativeKey());
        return (T) (rawValue != null ? Float.valueOf(rawValue * 10.0f) : null);
    }
    
    return get(key.getNativeKey());
}
```

## 呼叫鏈

```
App 呼叫 CaptureResult.get(LENS_FOCUS_DISTANCE)
    ↓
CaptureResult.get(key)  ← 線索 log
    ↓ mResults.get(key)
CameraMetadataNative.get(CaptureResult.Key)  ← BUG：乘以 10
    ↓ get(key.getNativeKey())
native 層取值
```

## 追蹤方法

1. 觀察 CTS 測試：LENS_FOCUS_DISTANCE 值異常大
2. 在 `CaptureResult.get()` 看到轉換相關 log
3. 追蹤到 `CameraMetadataNative.get()`
4. 發現對特定 key 有錯誤的乘法運算

## 修復方法

**文件 2（必須修復）：**
```java
public <T> T get(CaptureResult.Key<T> key) {
    // 移除錯誤的 focus distance 處理
    // LENS_FOCUS_DISTANCE 單位是 diopters，不需要額外轉換
    
    return get(key.getNativeKey());
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest CaptureResultTest#testCaptureResultGet`
4. 測試應該通過

## 學習重點
- CaptureResult 和 CameraMetadataNative 是委派關係
- metadata 值不應該被框架層修改
- LENS_FOCUS_DISTANCE 單位是 diopters（1/m）
