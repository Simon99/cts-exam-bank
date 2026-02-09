# Q003 答案：CameraCharacteristics LENS_FACING 返回 null

## 問題根因

在 `CameraMetadataNative.java` 的 `get()` 方法中，對 LENS_FACING key 做了特殊處理，錯誤地返回了 null。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
public <T> T get(CameraCharacteristics.Key<T> key) {
    // BUG: 對 LENS_FACING 做了錯誤的特殊處理
    if (key.getName().equals("android.lens.facing")) {
        return null;  // 錯誤：強制返回 null
    }
    return getBase(key);
}
```

## 修復方法

```java
public <T> T get(CameraCharacteristics.Key<T> key) {
    // 移除對 LENS_FACING 的特殊處理，使用正常的 getBase 邏輯
    return getBase(key);
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CameraManagerTest#testCameraManagerGetDeviceIdList`
4. 測試應該通過

## 學習重點
- CameraCharacteristics 包含相機的靜態屬性
- LENS_FACING 是 CTS 測試會驗證的必要屬性
- 特殊處理（hardcoded 返回值）是常見的 bug 類型
