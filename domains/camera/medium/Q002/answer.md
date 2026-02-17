# Q002 答案：Partial Result Count 不一致

## 問題根因

在 `CameraMetadataNative.java` 中，`REQUEST_PARTIAL_RESULT_COUNT` 的值被錯誤地設置得過低。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
// BUG: 強制返回錯誤的 partial result count
public <T> T get(CameraCharacteristics.Key<T> key) {
    if (key.getName().equals("android.request.partialResultCount")) {
        return (T) Integer.valueOf(3);  // 報告 3，但實際發送更多
    }
    return getBase(key);
}
```

**文件 2：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
// 實際發送了 5 個 partial results
private void sendPartialCaptureResult() {
    for (int i = 0; i < 5; i++) {  // 應該用 mTotalPartialCount
        // 發送 partial result
    }
}
```

## 修復方法

確保報告的 count 和實際發送的數量一致：

```java
// 使用正確的 partial result count
private void sendPartialCaptureResult() {
    for (int i = 0; i < mTotalPartialCount; i++) {
        // 發送 partial result
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CaptureResultTest#testPartialResult`
4. 測試應該通過

## 學習重點
- Partial results 是將 capture metadata 分批返回的機制
- 報告的 count 和實際行為必須一致
- 需要同時檢查 characteristics 報告和實際回調
