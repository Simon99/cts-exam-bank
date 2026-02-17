# Q010 答案：Reprocessing 的 JPEG Output 錯誤被拒絕

## 問題根因

這是一個跨兩個檔案的 bug：
1. **線索檔案** `OutputConfiguration.java`：`addSurface()` 有 log 顯示 surface 格式
2. **根因檔案** `CameraDeviceImpl.java`：錯誤地對 JPEG 格式拋出異常

## Bug 位置

**文件 1（線索）：** `frameworks/base/core/java/android/hardware/camera2/params/OutputConfiguration.java`

```java
public @NonNull OutputConfiguration addSurface(@NonNull Surface surface) {
    // 線索 log：顯示 surface 格式
    if (surface != null) {
        int format = SurfaceUtils.getSurfaceFormat(surface);
        Log.d(TAG, "Adding surface with format: " + format + 
              " (JPEG=" + ImageFormat.JPEG + ")");
    }
    
    // ... 正常邏輯
}
```

**文件 2（根因）：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
private void checkInputConfigurationWithStreamConfigurations(
        InputConfiguration inputConfig,
        @Nullable OutputConfiguration output) throws CameraAccessException {
    
    // BUG: 錯誤地排除 JPEG 格式
    if (output != null && output.getSurface() != null) {
        int format = SurfaceUtils.getSurfaceFormat(output.getSurface());
        if (format == ImageFormat.JPEG) {
            throw new CameraAccessException(CameraAccessException.CAMERA_ERROR,
                    "Output surface format not in supported list");
        }
    }
    
    // ... 正常的 stream configuration 檢查
}
```

## 呼叫鏈

```
App 建立 reprocessing session with JPEG output
    ↓
OutputConfiguration.addSurface(jpegSurface)  ← 線索 log
    ↓
CameraDevice.createReprocessableCaptureSession()
    ↓
CameraDeviceImpl.checkInputConfigurationWithStreamConfigurations()  ← BUG
    ↓
拋出 CameraAccessException（對 JPEG 格式）
```

## 追蹤方法

1. 觀察 CTS 測試：createReprocessableCaptureSession 對 JPEG output 失敗
2. 在 `OutputConfiguration.addSurface()` 看到 log 顯示 format=JPEG
3. 追蹤到 `CameraDeviceImpl.checkInputConfigurationWithStreamConfigurations()`
4. 發現對 JPEG 格式有錯誤的拒絕邏輯

## 修復方法

**文件 2（必須修復）：**
```java
private void checkInputConfigurationWithStreamConfigurations(
        InputConfiguration inputConfig,
        @Nullable OutputConfiguration output) throws CameraAccessException {
    
    // 移除錯誤的 JPEG 格式檢查
    // JPEG 是 reprocessing 的合法 output 格式
    
    StreamConfigurationMap streamConfigs = mCharacteristics.get(
            CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
    // ... 正常檢查
}
```

## 驗證方法

1. 還原兩個 patch
2. 重新編譯 framework
3. 執行 `atest ReprocessCaptureTest#testReprocessJpeg`
4. 測試應該通過

## 學習重點
- Reprocessing 允許將 RAW/YUV 重新處理為 JPEG
- JPEG 是 reprocessing 的有效 output 格式
- 格式檢查應該使用 StreamConfigurationMap，不是硬編碼
