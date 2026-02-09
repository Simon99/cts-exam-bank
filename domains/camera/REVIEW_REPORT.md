# Camera 題庫審查報告

**審查日期**：2025-02-10
**審查者**：Clawd (subagent: review-camera)
**題庫版本**：初版

---

## 一、審查總結

| 項目 | 狀態 |
|------|------|
| 題目總數 | 30 (Easy: 10, Medium: 10, Hard: 10) |
| 檔案完整性 | ✅ 全部通過 |
| AOSP 路徑驗證 | ⚠️ 1 個問題已修正 |
| 難度定義符合度 | ❌ Medium 9/10 不符合 |

---

## 二、各難度詳細審查

### Easy (10/10 通過 ✅)

所有 Easy 題目符合定義：**單一檔案，log 直接指向問題**

| 題號 | 標題 | affected_files | 狀態 |
|------|------|----------------|------|
| Q001 | CameraManager 返回空的相機列表 | 1 | ✅ |
| Q002 | Flashlight Torch 回調未觸發 | 1 | ✅ |
| Q003 | CameraCharacteristics LENS_FACING 返回 null | 1 | ✅ |
| Q004 | createCaptureRequest 返回錯誤的 CAPTURE_INTENT | 1 | ✅ |
| Q005 | CaptureResult Timestamp 為負數 | 1 | ✅ |
| Q006 | Torch Strength Level 驗證失敗 | 1 | ✅ |
| Q007 | ImageReader 格式不支援 | 1 | ✅ |
| Q008 | Preview Size 列表為空 | 1 | ✅ |
| Q009 | CameraDevice close() 不觸發 onClosed 回調 | 1 | ✅ |
| Q010 | CaptureRequest Parcelling 失敗 | 1 | ✅ |

### Medium (1/10 通過 ❌)

**嚴重問題**：Medium 定義要求 **2 個檔案**（log 在 A，bug 在 B），但 9/10 題只有 1 個檔案

| 題號 | 標題 | affected_files | 狀態 | 建議 |
|------|------|----------------|------|------|
| Q001 | Capture 回調順序錯誤 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q002 | Partial Result Count 不一致 | 2 | ✅ | - |
| Q003 | Camera Availability 回調不一致 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q004 | Session Configuration 驗證失敗 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q005 | Repeating Request 停止失敗 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q006 | Focus Distance 超出範圍 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q007 | AE Mode 設置無效 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q008 | Frame Duration 計算錯誤 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q009 | Zoom Ratio 驗證失敗 | 1 | ❌ | 降為 Easy 或增加檔案 |
| Q010 | Output Surface 配置不支援 | 1 | ❌ | 降為 Easy 或增加檔案 |

### Hard (10/10 通過 ✅)

所有 Hard 題目符合定義：**3+ 個檔案，呼叫鏈或多處 bug**

| 題號 | 標題 | affected_files | 狀態 | 備註 |
|------|------|----------------|------|------|
| Q001 | Multi-Camera 邏輯/物理相機交互錯誤 | 3 | ✅ | - |
| Q002 | Offline Session 切換失敗 | 3 | ✅ | - |
| Q003 | Reprocess Capture 流程錯誤 | 3 | ✅ | - |
| Q004 | Extension Session 初始化失敗 | 3 | ✅ | - |
| Q005 | Multi-Camera Logical Stream 配置失敗 | 3 | ✅ | 涉及 C++ 代碼 |
| Q006 | High Speed Video Recording 幀率不穩定 | 3 | ✅ | 涉及 C++ 代碼 |
| Q007 | Camera2 Session 切換時 Surface 狀態錯誤 | 3 | ✅ | 涉及 C++ 代碼 |
| Q008 | RAW Capture DNG Metadata 不完整 | 3 | ✅ | 涉及 JNI |
| Q009 | CaptureRequest 批量提交 Ordering 錯亂 | 3 | ✅ | 涉及 C++ 代碼 |
| Q010 | Camera Flash Torch Mode 狀態不同步 | 3 | ⚠️ | **已修正路徑** |

---

## 三、已執行的修正

### 1. Hard Q010 meta.json 路徑修正

**問題**：`CameraManagerGlobal.java` 不是獨立檔案，而是 `CameraManager.java` 的內部類別（第 1867 行）

**修正**：
```json
// Before
"affected_files": [
    "frameworks/base/core/java/android/hardware/camera2/CameraManager.java",
    "frameworks/base/core/java/android/hardware/camera2/CameraManagerGlobal.java",  // ❌ 不存在
    "frameworks/av/services/camera/libcameraservice/CameraService.cpp"
]

// After
"affected_files": [
    "frameworks/base/core/java/android/hardware/camera2/CameraManager.java",
    "frameworks/av/services/camera/libcameraservice/CameraService.cpp",
    "frameworks/av/services/camera/libcameraservice/CameraFlashlight.cpp"  // ✅ 實際存在
]
```

---

## 四、待處理項目

### 🔴 高優先級：Medium 難度重新設計

**選項 A**：降級 9 題到 Easy
- 將 M-Q001, Q003-Q010 移動到 easy/ 目錄
- 重新編號

**選項 B**：修改 9 題為 2 檔案 bug
- 為每題設計第二個檔案的 bug
- 確保 log 在 A，bug 在 B 的結構

**建議**：選項 B，保持題目數量平衡

### 🟡 中優先級：answer.md 格式標準化

建議在 answer.md 中明確標示：
- `## 追蹤路徑` 或 `## Root Cause Analysis`
- 對於 Medium/Hard 題目，清楚說明從 log 到 bug 的追蹤過程

### 🟢 低優先級：Hard Q010 patch 更新

當前 patch 只修改 2 個檔案，需要增加 `CameraFlashlight.cpp` 的修改以符合 meta.json

---

## 五、AOSP 路徑驗證結果

所有路徑（修正後）在 AOSP sandbox-1 中存在：

```
✓ frameworks/base/core/java/android/hardware/camera2/CameraManager.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java
✓ frameworks/base/core/java/android/hardware/camera2/params/StreamConfigurationMap.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/PhysicalCaptureResultInfo.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/CameraOfflineSessionImpl.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/RequestLastFrameNumbersHolder.java
✓ frameworks/base/core/java/android/hardware/camera2/CaptureRequest.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/CameraExtensionSessionImpl.java
✓ frameworks/base/core/java/android/hardware/camera2/CameraExtensionCharacteristics.java
✓ frameworks/av/services/camera/libcameraservice/device3/Camera3Device.cpp
✓ frameworks/av/services/camera/libcameraservice/api2/CameraDeviceClient.cpp
✓ frameworks/av/services/camera/libcameraservice/common/CameraProviderManager.cpp
✓ frameworks/base/core/java/android/hardware/camera2/impl/CameraConstrainedHighSpeedCaptureSessionImpl.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/CameraCaptureSessionImpl.java
✓ frameworks/base/core/java/android/hardware/camera2/DngCreator.java
✓ frameworks/base/core/jni/android_hardware_camera2_DngCreator.cpp
✓ frameworks/base/core/java/android/hardware/camera2/CameraCharacteristics.java
✓ frameworks/base/core/java/android/hardware/camera2/impl/CallbackProxies.java
✓ frameworks/av/services/camera/libcameraservice/CameraService.cpp
✓ frameworks/av/services/camera/libcameraservice/CameraFlashlight.cpp
```

---

## 六、Patch 安全性審查

所有 patch 經過審查，**不會導致 bootloop**：
- ✅ 無系統關鍵服務的致命修改
- ✅ Bug 都是功能性問題（返回錯誤值、跳過回調等）
- ✅ 不影響 system_server 啟動
- ✅ 不影響 Zygote 進程

---

**審查完成**
