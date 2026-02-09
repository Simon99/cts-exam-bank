# Q003: CameraCharacteristics LENS_FACING 返回 null

## CTS 測試失敗現象

執行 CTS 測試 `CameraManagerTest#testCameraManagerGetDeviceIdList` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraManagerTest#testCameraManagerGetDeviceIdList

junit.framework.AssertionFailedError: Can't get lens facing info
    at junit.framework.Assert.fail(Assert.java:50)
    at junit.framework.Assert.assertNotNull(Assert.java:234)
    at android.hardware.camera2.cts.CameraManagerTest.testCameraManagerGetDeviceIdList(CameraManagerTest.java:162)
```

## 測試環境
- 設備有相機
- getCameraIdList() 返回正確的相機 ID
- getCameraCharacteristics(id) 返回 CameraCharacteristics 物件
- 但 characteristics.get(LENS_FACING) 返回 null

## 重現步驟
1. 執行 `atest CameraManagerTest#testCameraManagerGetDeviceIdList`
2. 測試失敗在 assertNotNull("Can't get lens facing info", lensFacing)

## 期望行為
- CameraCharacteristics.LENS_FACING 是必要的 key
- 每個相機都應該報告其鏡頭朝向（FRONT, BACK, 或 EXTERNAL）

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraManagerTest.java`
- Characteristics 的 get 方法位於 `frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java`
