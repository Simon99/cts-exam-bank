# Q001: CameraManager 返回空的相機列表

## CTS 測試失敗現象

執行 CTS 測試 `CameraManagerTest#testCameraManagerGetDeviceIdList` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraManagerTest#testCameraManagerGetDeviceIdList

junit.framework.AssertionFailedError: System camera feature and camera id list don't match
    at junit.framework.Assert.fail(Assert.java:50)
    at junit.framework.Assert.assertTrue(Assert.java:20)
    at android.hardware.camera2.cts.CameraManagerTest.testCameraManagerGetDeviceIdList(CameraManagerTest.java:142)
```

## 測試環境
- 設備有前後鏡頭
- PackageManager 報告有 FEATURE_CAMERA 和 FEATURE_CAMERA_FRONT
- 但 CameraManager.getCameraIdList() 返回空陣列

## 重現步驟
1. 執行 `atest CameraManagerTest#testCameraManagerGetDeviceIdList`
2. 測試失敗，提示相機功能和相機列表不匹配

## 期望行為
- 設備有相機時，getCameraIdList() 應該返回非空的相機 ID 列表
- 相機功能 flag 和相機數量應該一致

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraManagerTest.java`
- Framework 實現位於 `frameworks/base/core/java/android/hardware/camera2/CameraManager.java`
