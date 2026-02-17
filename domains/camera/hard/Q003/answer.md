# Q003 答案：Reprocess Capture 流程錯誤

## 問題根因

在 reprocess capture 流程中，input image 的 buffer 沒有被正確傳遞到 HAL。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
private int submitCaptureRequest(List<CaptureRequest> requestList, ...) {
    for (CaptureRequest request : requestList) {
        // BUG: 沒有檢查 reprocess request 的特殊處理
        if (request.isReprocess()) {
            // 應該設置 input stream ID，但被跳過了
            continue;  // 錯誤！
        }
        // ...
    }
}
```

**文件 2：** `frameworks/base/core/java/android/hardware/camera2/CaptureRequest.java`

```java
public boolean isReprocess() {
    // BUG: 總是返回 false
    return false;  // 應該根據實際情況返回
}
```

**文件 3：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
// Reprocess 的 input stream ID 設置
public void setInputStreamId(int streamId) {
    // BUG: 沒有實際設置 stream ID
    // mInputStreamId = streamId;  // 被註釋掉了
}
```

## 修復方法

```java
// CaptureRequest.java
public boolean isReprocess() {
    return mIsReprocess;  // 返回正確的狀態
}

// CameraDeviceImpl.java - 正確處理 reprocess request
if (request.isReprocess()) {
    // 設置 input stream ID 和其他必要參數
    request.setInputStreamId(mConfiguredInput.getKey());
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest ReprocessCaptureTest#testReprocessJpeg`
4. 測試應該通過

## 學習重點
- Reprocess 是用已有的 image 重新處理的機制
- 需要正確配置 input stream 和 output stream
- Request 的類型判斷影響整個處理流程
