# Q008 答案：Preview Size 列表為空

## 問題根因

在 `StreamConfigurationMap.java` 的 `getOutputSizes()` 方法中，對 SurfaceHolder class 返回了空陣列。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/params/StreamConfigurationMap.java`

```java
public Size[] getOutputSizes(Class<?> klass) {
    // BUG: 對 SurfaceHolder 返回空陣列
    if (klass == android.view.SurfaceHolder.class) {
        return new Size[0];  // 錯誤！
    }
    
    // 正常的 size 查詢邏輯
    return getOutputSizesForClass(klass);
}
```

## 修復方法

```java
public Size[] getOutputSizes(Class<?> klass) {
    // 移除對 SurfaceHolder 的特殊處理
    // 使用統一的 size 查詢邏輯
    return getOutputSizesForClass(klass);
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest SurfaceViewPreviewTest#testCameraPreview`
4. 測試應該通過

## 學習重點
- StreamConfigurationMap 管理所有支援的輸出配置
- getOutputSizes() 是獲取支援 size 的標準方法
- 對特定 class 的特殊處理可能導致功能異常
