# Q007 答案：自動曝光模式被覆蓋

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `CaptureRequest.java`：`Builder.set()` 有 log 顯示設定值
2. **根因檔案** `CameraMetadataNative.java`：強制將 AE_MODE 改為 OFF

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/CaptureRequest.java`

```java
// Builder 內部類
public <T> void set(@NonNull Key<T> key, T value) {
    // 線索 log：顯示 App 設定的值
    if ("android.control.aeMode".equals(key.getName())) {
        Log.d(TAG, "Setting AE mode to: " + value + 
              " (will be processed by metadata layer)");
    }
    
    mRequest.mLogicalCameraSettings.set(key, value);  // 呼叫 CameraMetadataNative
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
public <T> void set(CaptureRequest.Key<T> key, T value) {
    // BUG: 強制覆蓋 AE_MODE 為 OFF
    if ("android.control.aeMode".equals(key.getName())) {
        value = (T) Integer.valueOf(CameraMetadata.CONTROL_AE_MODE_OFF);
    }
    
    set(key.getNativeKey(), value);
}
```

## 呼叫鏈

```
App 呼叫 CaptureRequest.Builder.set(CONTROL_AE_MODE, ON)
    ↓
CaptureRequest.Builder.set(key, value)  ← 線索 log 顯示 "ON"
    ↓ mLogicalCameraSettings.set(key, value)
CameraMetadataNative.set(CaptureRequest.Key, value)  ← BUG：改為 OFF
    ↓ set(key.getNativeKey(), OFF)
native 層儲存 OFF
```

## 追蹤方法

1. 觀察 CTS 測試：AE 模式永遠是 OFF
2. 在 `CaptureRequest.Builder.set()` 看到 log 顯示正確的設定值
3. 但 CaptureResult 中取得的值是 OFF
4. 追蹤到 `CameraMetadataNative.set()` 發現覆蓋邏輯

## 修復方法

**文件 2（必須修復）：**
```java
public <T> void set(CaptureRequest.Key<T> key, T value) {
    // 移除錯誤的 AE_MODE 覆蓋
    // AE_MODE 應該使用 App 設定的值
    
    set(key.getNativeKey(), value);
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest CaptureRequestTest#testAeModes`
4. 測試應該通過

## 學習重點
- CaptureRequest.Builder 和 CameraMetadataNative 是組合關係
- metadata 層不應該覆蓋 App 的設定
- AE_MODE 控制自動曝光行為，對拍照結果有重大影響
