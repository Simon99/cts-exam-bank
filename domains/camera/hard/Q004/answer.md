# Q004 答案：Extension Session 初始化失敗

## 問題根因

在 Extension session 初始化流程中，extension type 的驗證邏輯有誤。

## Bug 位置

**文件 1：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraExtensionSessionImpl.java`

```java
private void initialize(ExtensionSessionConfiguration config) {
    int extensionType = config.getExtension();
    
    // BUG: 錯誤的 extension type 驗證
    if (extensionType == CameraExtensionCharacteristics.EXTENSION_NIGHT) {
        notifyConfigureFailed();  // 錯誤地標記為不支援
        return;
    }
    
    // ...正常初始化
}
```

**文件 2：** `frameworks/base/core/java/android/hardware/camera2/CameraExtensionCharacteristics.java`

```java
public List<Integer> getSupportedExtensions() {
    List<Integer> extensions = new ArrayList<>();
    // BUG: NIGHT 被加入 supported 列表，但實際初始化會失敗
    extensions.add(EXTENSION_NIGHT);
    // ...
    return extensions;
}
```

**文件 3：** `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java`

```java
// Extension session 創建的入口點
public void createExtensionSession(ExtensionSessionConfiguration config) {
    // 沒有正確驗證 extension 是否真的可用
}
```

## 修復方法

```java
// CameraExtensionSessionImpl.java
private void initialize(ExtensionSessionConfiguration config) {
    int extensionType = config.getExtension();
    
    // 移除錯誤的特殊處理，所有 supported 的 extension 都應該能初始化
    // 正常初始化流程
    setupExtension(extensionType);
    notifyConfigured();
}
```

## 驗證方法

1. 還原 patch
2. 重新編譯 framework
3. 執行 `atest CameraExtensionSessionTest#testExtensionSession`
4. 測試應該通過

## 學習重點
- Camera Extensions 是 Android 的相機增強功能
- getSupportedExtensions() 報告的必須都能實際使用
- Session 配置流程涉及多個類的協作
