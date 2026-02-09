# Q002: Offline Session 切換失敗

## CTS 測試失敗現象

執行 CTS 測試 `OfflineSessionTest#testOfflineSessionSwitch` 時失敗：

```
FAIL: android.hardware.camera2.cts.OfflineSessionTest#testOfflineSessionSwitch

junit.framework.AssertionFailedError: Offline session switch failed
Error: onSwitchFailed callback received
Error code: ERROR_CAMERA_DEVICE
Pending capture count: 5
Completed offline captures: 0

    at android.hardware.camera2.cts.OfflineSessionTest.testOfflineSessionSwitch(OfflineSessionTest.java:345)
```

## 測試環境
- 相機支援 OFFLINE_PROCESSING capability
- 嘗試切換到 offline session
- switchToOffline() 返回成功
- 但隨後收到 onSwitchFailed 回調

## 重現步驟
1. 執行 `atest OfflineSessionTest#testOfflineSessionSwitch`
2. 測試失敗，offline session 切換後失敗

## 期望行為
- switchToOffline() 成功後應該收到 onReady 回調
- Pending captures 應該在 offline session 中完成
- 不應該收到 onSwitchFailed

## 提示
- 測試邏輯位於 `cts/tests/camera/src/android/hardware/camera2/cts/OfflineSessionTest.java`
- Offline session 創建位於 `CameraDeviceImpl.java`
- Offline 處理位於 `CameraOfflineSessionImpl.java`
- Pending request 追蹤位於 `RequestLastFrameNumbersHolder.java`
