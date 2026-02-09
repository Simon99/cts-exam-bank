# Q004 答案：createCaptureRequest 返回錯誤的 CAPTURE_INTENT

## 問題根因

在 `CameraDeviceImpl.java` 的 `createCaptureRequest()` 方法中，template ID 的處理有誤，導致 PREVIEW template 被錯誤地當作 STILL_CAPTURE 處理。

## Bug 位置

文件：`frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
@Override
public CaptureRequest.Builder createCaptureRequest(int templateType)
        throws CameraAccessException {
    synchronized(mInterfaceLock) {
        checkIfCameraClosedOrInError();
        
        // BUG: PREVIEW 被改成 STILL_CAPTURE
        if (templateType == CameraDevice.TEMPLATE_PREVIEW) {
            templateType = CameraDevice.TEMPLATE_STILL_CAPTURE;  // 錯誤！
        }
        
        CameraMetadataNative templatedRequest =
            mRemoteDevice.createDefaultRequest(templateType);
        // ...
    }
}
```

## 修復方法

```java
@Override
public CaptureRequest.Builder createCaptureRequest(int templateType)
        throws CameraAccessException {
    synchronized(mInterfaceLock) {
        checkIfCameraClosedOrInError();
        
        // 移除錯誤的 template 替換
        // 直接使用原始的 templateType
        
        CameraMetadataNative templatedRequest =
            mRemoteDevice.createDefaultRequest(templateType);
        // ...
    }
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CameraDeviceTest#testCameraDevicePreviewTemplate`
4. 測試應該通過

## 學習重點
- CaptureRequest templates 定義了不同拍攝場景的預設參數
- CAPTURE_INTENT 是 CTS 會驗證的關鍵 metadata
- Template ID 到 Intent 的映射必須正確
