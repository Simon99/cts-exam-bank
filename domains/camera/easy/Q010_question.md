# Q010: CaptureRequest Parcelling 失敗

## CTS 測試失敗現象

執行 CTS 測試 `CaptureRequestTest#testSettingsBinderParcel` 時失敗：

```
FAIL: android.hardware.camera2.cts.CaptureRequestTest#testSettingsBinderParcel

junit.framework.AssertionFailedError: Parcelled camera settings should match
Expected: CONTROL_CAPTURE_INTENT_PREVIEW
Actual: null

    at android.hardware.camera2.cts.CaptureRequestTest.testSettingsBinderParcel(CaptureRequestTest.java:197)
```

## 測試環境
- CaptureRequest 可以正常創建
- 寫入 Parcel 成功
- 從 Parcel 讀取後，CONTROL_CAPTURE_INTENT 變成 null

## 重現步驟
1. 執行 `atest CaptureRequestTest#testSettingsBinderParcel`
2. 測試在驗證 parcelled request 時失敗

## 期望行為
- CaptureRequest 經過 Parcel 序列化/反序列化後
- 所有 metadata 應該保持不變
- get() 應該返回原本設置的值

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CaptureRequestTest.java`
- Parcel 邏輯位於 `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`
