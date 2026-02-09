# Q006 答案：Torch Strength Level 驗證失敗

## 問題根因

在 `CameraManager.java` 的 `getTorchStrengthLevel()` 方法中，返回了錯誤的固定值。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/CameraManager.java`

```java
public int getTorchStrengthLevel(@NonNull String cameraId) 
        throws CameraAccessException {
    // BUG: 忽略實際的 strength level，總是返回 1
    return 1;  // 錯誤！應該返回實際的 torch strength
}
```

## 修復方法

```java
public int getTorchStrengthLevel(@NonNull String cameraId) 
        throws CameraAccessException {
    // 正確實現：從 camera service 獲取實際的 torch strength
    synchronized (mLock) {
        ICameraService cameraService = CameraManagerGlobal.get().getCameraService();
        if (cameraService == null) {
            throw new CameraAccessException(CameraAccessException.CAMERA_DISCONNECTED);
        }
        return cameraService.getTorchStrengthLevel(cameraId);
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest FlashlightTest#testTurnOnTorchWithStrengthLevel`
4. 測試應該通過

## 學習重點
- Torch strength 是 Android 支援的閃光燈亮度調整功能
- getter 方法必須返回實際狀態，不能返回固定值
- CTS 會驗證 set/get 的一致性
