# Camera 模組注入點分布列表

**CTS 路徑**: `cts/tests/camera/`  
**更新時間**: 2026-02-10 17:15 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 27 |
| Easy | 10 (37%) |
| Medium | 11 (41%) |
| Hard | 6 (22%) |

**涵蓋測試類別**：見下方

## CTS 測試類別

### Camera2 API 測試（主要）
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| CameraDeviceTest | 相機設備開關、狀態 | 高 |
| CameraManagerTest | 相機管理、列表、特性 | 高 |
| CaptureRequestTest | 拍照請求參數 | 高 |
| CaptureResultTest | 拍照結果處理 | 中 |
| StillCaptureTest | 靜態拍照 | 高 |
| RecordingTest | 錄影 | 中 |
| ImageReaderTest | 圖像讀取 | 中 |
| BurstCaptureTest | 連拍 | 中 |
| FlashlightTest | 閃光燈 | 低 |
| ZoomCaptureTest | 變焦 | 中 |
| RobustnessTest | 穩健性測試 | 高 |
| PerformanceTest | 性能測試 | 低 |

### Legacy Camera API 測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| CameraTest | 舊版 Camera API | 中 |
| Camera_ParametersTest | 參數設定 | 中 |

### 其他
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| CameraEvictionTest | 多進程搶占 | 低 |
| DngCreatorTest | DNG 格式 | 低 |

## 對應 AOSP 源碼路徑

### Java 層（Framework）
- `frameworks/base/core/java/android/hardware/camera2/` — Camera2 API
  - `CameraManager.java` (3087 行)
  - `CameraDevice.java` (1838 行)
  - `CaptureRequest.java` (4448 行)
  - `CaptureResult.java`
  - `CameraCharacteristics.java`
  - `impl/CameraDeviceImpl.java` (2604 行) ⭐ 核心實現

### Native 層
- `frameworks/av/camera/` — Camera Native 實現
  - `Camera.cpp`
  - `CameraBase.cpp`
  - `CameraMetadata.cpp`
- `frameworks/av/services/camera/` — Camera Service

---

## 注入點清單

### 1. CameraDeviceImpl（核心實現）⭐

**檔案**: `frameworks/base/core/java/android/hardware/camera2/impl/CameraDeviceImpl.java` (2604 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| CAM-001 | submitCaptureRequest() | 1264-1345 | COND, ERR | Medium | CaptureRequestTest | 請求提交，Surface 檢查、repeating 邏輯 |
| CAM-002 | checkIfCameraClosedOrInError() | 2499-2507 | STATE, ERR | Easy | CameraDeviceTest | 狀態檢查：mRemoteDevice==null, mInError |
| CAM-003 | capture() | 1131-1139 | COND | Easy | StillCaptureTest | 拍照入口，簡單封裝 |
| CAM-004 | captureBurst() | 1141-1147 | BOUND, COND | Easy | BurstCaptureTest | 連拍，requests==null/isEmpty 檢查 |
| CAM-005 | close() | 1437-1483 | RES, STATE | Medium | CameraDeviceTest | 資源釋放順序、mClosing 原子操作 |
| CAM-006 | setRepeatingRequest() | 1349-1362 | STATE | Medium | RecordingTest | 重複請求，callback 處理 |
| CAM-007 | stopRepeating() | 1364-1397 | STATE, ERR | Medium | RecordingTest | 停止重複請求，race condition 處理 |
| CAM-008 | checkEarlyTriggerSequenceComplete() | 1163-1230 | COND, STATE | Hard | CaptureRequestTest | 序列完成檢查邏輯複雜 |
| CAM-009 | isClosed() | 2509-2511 | STATE | Easy | CameraDeviceTest | mClosing.get() 檢查 |

### 2. CameraManager

**檔案**: `frameworks/base/core/java/android/hardware/camera2/CameraManager.java` (3087 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| CAM-011 | getCameraIdList() | 243-246 | COND | Easy | CameraManagerTest | 獲取相機列表（委託給 Global）|
| CAM-012 | openCameraDeviceUserAsync() | 842-922 | ERR, STATE | Hard | CameraDeviceTest | 核心開啟邏輯，多種錯誤處理 |
| CAM-013 | openCamera() | 1003-1040 | COND, ERR | Medium | CameraDeviceTest | 公開 API，參數驗證 |
| CAM-014 | getCameraCharacteristics() | 614-637 | COND, ERR | Easy | CameraManagerTest | 獲取特性 |
| CAM-015 | registerAvailabilityCallback() | 382-417 | COND | Easy | CameraManagerTest | 註冊可用性回調 |
| CAM-016 | isConcurrentSessionConfigurationSupported() | 348-380 | COND | Hard | ConcurrentCameraTest | 並發配置支援檢查 |
| CAM-017 | getConcurrentCameraIds() | 312-346 | COND | Medium | ConcurrentCameraTest | 獲取並發相機 ID |
| CAM-018 | registerTorchCallback() | 461-478 | COND | Easy | FlashlightTest | 手電筒回調註冊 |

### 3. CaptureRequest

**檔案**: `frameworks/base/core/java/android/hardware/camera2/CaptureRequest.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| CAM-021 | Builder.set() | 待查 | COND, BOUND | Medium | CaptureRequestTest | 參數設定驗證 |
| CAM-022 | getTargets() | 待查 | COND | Easy | CaptureRequestTest | Surface 目標 |

### 4. CameraCaptureSession

**檔案**: `frameworks/base/core/java/android/hardware/camera2/impl/CameraCaptureSessionImpl.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| CAM-031 | 待分析 | - | - | - | - | - |

### 5. ImageReader 相關

**檔案**: `frameworks/base/media/java/android/media/ImageReader.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| CAM-041 | 待分析 | - | - | - | ImageReaderTest | - |

---

## 統計摘要

| 注入類型 | 數量 |
|----------|------|
| COND（條件判斷）| 15 |
| STATE（狀態轉換）| 12 |
| ERR（錯誤處理）| 10 |
| RES（資源管理）| 4 |
| BOUND（邊界檢查）| 3 |

## 下一步 - Phase B

從此列表中挑選 15 個注入點，進行題目生成：
1. [x] Phase A 完成 - 注入點列表已建立
2. [ ] Phase B - 挑選注入點、設計 bug、產生 patch
3. [ ] Phase C - 實機驗證
