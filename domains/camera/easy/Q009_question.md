# Q009: CameraDevice close() 不觸發 onClosed 回調

## CTS 測試失敗現象

執行 CTS 測試 `CameraDeviceTest#testCameraDeviceClose` 時失敗：

```
FAIL: android.hardware.camera2.cts.CameraDeviceTest#testCameraDeviceClose

org.mockito.exceptions.verification.WantedButNotInvoked: 
Wanted but not invoked:
    mockCallback.onClosed(<any CameraDevice>);

Actually, there were zero interactions with this mock.
    at android.hardware.camera2.cts.CameraDeviceTest.testCameraDeviceClose(CameraDeviceTest.java:523)
```

## 測試環境
- CameraDevice 可以正常開啟
- 調用 close() 後設備確實關閉
- 但 StateCallback.onClosed() 從未被調用

## 重現步驟
1. 執行 `atest CameraDeviceTest#testCameraDeviceClose`
2. 測試超時，等不到 onClosed 回調

## 期望行為
- 調用 CameraDevice.close() 後
- 應該觸發 StateCallback.onClosed(camera) 回調
- App 依賴此回調來確認相機已完全釋放

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java`
- Close 邏輯位於 `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`
