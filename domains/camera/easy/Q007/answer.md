# Q007 答案：ImageReader 格式不支援

## 問題根因

在 `CameraMetadataNative.java` 的 StreamConfigurationMap 生成邏輯中，YUV_420_888 格式被錯誤地排除了。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
private StreamConfigurationMap getStreamConfigurationMap() {
    // BUG: 排除了 YUV_420_888 格式
    ArrayList<Integer> supportedFormats = new ArrayList<>();
    for (int format : rawFormats) {
        if (format == ImageFormat.YUV_420_888) {
            continue;  // 錯誤：跳過 YUV_420_888
        }
        supportedFormats.add(format);
    }
    // ...
}
```

## 修復方法

```java
private StreamConfigurationMap getStreamConfigurationMap() {
    // 不要排除任何格式，讓所有支援的格式都被報告
    ArrayList<Integer> supportedFormats = new ArrayList<>();
    for (int format : rawFormats) {
        supportedFormats.add(format);  // 包含所有格式
    }
    // ...
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest ImageReaderTest#testFlexibleYuv`
4. 測試應該通過

## 學習重點
- YUV_420_888 是 Camera2 API 強制要求的格式
- StreamConfigurationMap 定義了相機支援的輸出格式
- 格式過濾錯誤會導致 API 層面的功能缺失
