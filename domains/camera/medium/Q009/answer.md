# Q009 答案：縮放比例設定無效

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `CaptureRequest.java`：`Builder.set()` 有 log 顯示要求的 zoom ratio
2. **根因檔案** `CameraMetadataNative.java`：強制將 ZOOM_RATIO 改為 1.0

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/CaptureRequest.java`

```java
// Builder 內部類
public <T> void set(@NonNull Key<T> key, T value) {
    // 線索 log：顯示 App 要求的 zoom ratio
    if ("android.control.zoomRatio".equals(key.getName())) {
        Log.d(TAG, "Requested zoom ratio: " + value + 
              " (forwarding to metadata layer)");
    }
    
    mRequest.mLogicalCameraSettings.set(key, value);  // 呼叫 CameraMetadataNative
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
public <T> void set(CaptureRequest.Key<T> key, T value) {
    // BUG: 強制覆蓋 ZOOM_RATIO 為 1.0
    if ("android.control.zoomRatio".equals(key.getName())) {
        value = (T) Float.valueOf(1.0f);  // 無論 App 設什麼，都變成 1.0
    }
    
    set(key.getNativeKey(), value);
}
```

## 呼叫鏈

```
App 呼叫 CaptureRequest.Builder.set(CONTROL_ZOOM_RATIO, 2.0f)
    ↓
CaptureRequest.Builder.set(key, 2.0f)  ← 線索 log 顯示 "2.0"
    ↓ mLogicalCameraSettings.set(key, 2.0f)
CameraMetadataNative.set(key, 2.0f)  ← BUG：改為 1.0f
    ↓ set(key.getNativeKey(), 1.0f)
native 層儲存 1.0f
```

## 追蹤方法

1. 觀察 CTS 測試：設定 zoom ratio 2.0，但拍出來的畫面沒有放大
2. 在 `CaptureRequest.Builder.set()` 看到 log 顯示 "Requested zoom ratio: 2.0"
3. 但 CaptureResult 中取得的 ZOOM_RATIO 是 1.0
4. 追蹤到 `CameraMetadataNative.set()` 發現覆蓋邏輯

## 修復方法

**文件 2（必須修復）：**
```java
public <T> void set(CaptureRequest.Key<T> key, T value) {
    // 移除錯誤的 ZOOM_RATIO 覆蓋
    // zoom ratio 應該使用 App 設定的值
    
    set(key.getNativeKey(), value);
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest CaptureRequestTest#testZoomRatio`
4. 測試應該通過

## 學習重點
- ZOOM_RATIO 是 Android 11+ 新增的縮放 API
- metadata 層不應該覆蓋 App 的縮放設定
- 1.0f 表示無縮放，>1.0f 表示放大
