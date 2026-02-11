# Camera2 設備錯誤狀態檢查異常

## 情境

QA 團隊發現一個奇怪的現象：Camera2 設備在正常運作時會拋出 `CameraAccessException`，但當設備真正發生錯誤時卻能繼續操作。

## 問題程式碼

```java
// CameraDeviceImpl.java - checkIfCameraClosedOrInError()
private void checkIfCameraClosedOrInError() throws CameraAccessException {
    if (mRemoteDevice == null) {
        throw new IllegalStateException("CameraDevice was already closed");
    }
    if (!mInError) {
        throw new CameraAccessException(CameraAccessException.CAMERA_ERROR,
                "The camera device has encountered a serious error");
    }
}
```

## 問題

上述程式碼中的 bug 會導致什麼問題？

## 選項

A. 應該使用 `mRemoteDevice != null` 而非 `mRemoteDevice == null`

B. `!mInError` 的邏輯反轉了，應該是 `mInError` 才拋出異常

C. 兩個異常類型用錯了，應該互換 `IllegalStateException` 和 `CameraAccessException`

D. 缺少對 `mClosing` 狀態的檢查
