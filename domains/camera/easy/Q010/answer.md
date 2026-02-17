# Q010 答案：CaptureRequest Parcelling 失敗

## 問題根因

在 `CameraMetadataNative.java` 的 `readFromParcel()` 方法中，metadata 沒有被正確讀取。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`

```java
@Override
public void readFromParcel(Parcel in) {
    // BUG: 沒有正確讀取 metadata
    nativeReadFromParcel(in);
    // 錯誤：在讀取後清空了 metadata
    nativeClear();  // 這會清除剛讀取的數據！
}
```

## 修復方法

```java
@Override
public void readFromParcel(Parcel in) {
    // 正確實現：只讀取，不清空
    nativeReadFromParcel(in);
    // 移除 nativeClear() 調用
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CaptureRequestTest#testSettingsBinderParcel`
4. 測試應該通過

## 學習重點
- CaptureRequest 可以通過 Parcel 跨進程傳遞
- Parcelable 的序列化/反序列化必須保持數據完整
- 多餘的清空操作會破壞數據
