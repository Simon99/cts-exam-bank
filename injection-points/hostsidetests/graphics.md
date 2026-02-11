# Graphics 模組注入點分布列表

**CTS 路徑**: `cts/hostsidetests/graphics/`  
**更新時間**: 2026-02-10 18:30 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 32 |
| Easy | 12 (38%) |
| Medium | 14 (44%) |
| Hard | 6 (18%) |

**涵蓋測試類別**：GPU Metrics、GPU Profiling、Display Mode

## CTS 測試類別

### GPU Metrics 測試
| 測試類別 | 檔案 | 描述 | 優先級 |
|---------|------|------|--------|
| GpuWorkDumpsysTest | `gpumetrics/.../GpuWorkDumpsysTest.java` | GPU 工作時間 dumpsys 驗證 | 高 |

**測試重點**：
- 驗證 `dumpsys gpu --gpuwork` 輸出格式
- 確認 GPU 工作時間追蹤功能正常
- 檢查 UID 對應的 GPU active/inactive 時間

### GPU Profiling 測試
| 測試類別 | 檔案 | 描述 | 優先級 |
|---------|------|------|--------|
| CtsGpuProfilingDataTest | `gpuprofiling/.../CtsGpuProfilingDataTest.java` | GPU Profiling 數據源驗證 | 高 |
| CtsFrameTracerDataSourceTest | `gpuprofiling/.../CtsFrameTracerDataSourceTest.java` | Frame Tracer 數據驗證 | 中 |

**測試重點**：
- 驗證 Perfetto GPU 數據源（gpu.counters、gpu.renderstages）
- 檢查 GPU Counter 值的有效性
- Frame Tracer 數據完整性

### Display Mode 測試
| 測試類別 | 檔案 | 描述 | 優先級 |
|---------|------|------|--------|
| BootDisplayModeTest | `displaymode/.../BootDisplayModeTest.java` | 開機顯示模式設定 | 高 |
| BootDisplayModeHostTest | `displaymode/.../BootDisplayModeHostTest.java` | Host 端顯示模式驗證 | 中 |

**測試重點**：
- 驗證 `setUserPreferredDisplayMode` / `clearUserPreferredDisplayMode` API
- 開機後的顯示模式保持
- 多模式切換正確性

## 對應 AOSP 源碼路徑

### Native 層（SurfaceFlinger）
```
frameworks/native/services/surfaceflinger/
├── SurfaceFlinger.cpp          # 核心合成引擎（444KB，主要注入點）
├── DisplayDevice.cpp           # 顯示設備管理
├── Layer.cpp                   # 圖層管理
├── FpsReporter.cpp             # FPS 報告
├── FrameTracer/                # 幀追蹤
│   └── FrameTracer.cpp
├── Scheduler/                  # 刷新率調度
│   ├── RefreshRateSelector.cpp
│   ├── VsyncModulator.cpp
│   ├── Scheduler.cpp
│   └── EventThread.cpp
├── DisplayHardware/            # 硬體抽象層
│   ├── HWComposer.cpp
│   ├── PowerAdvisor.cpp
│   └── AidlComposerHal.cpp
└── RegionSamplingThread.cpp    # 區域採樣
```

### Java 層（Framework Graphics）
```
frameworks/base/graphics/java/android/graphics/
├── HardwareBufferRenderer.java  # 硬體緩衝渲染
├── Canvas.java
├── Bitmap.java
├── Paint.java
└── RenderNode.java
```

---

## 注入點清單

### 1. GPU Metrics（GPU 工作追蹤）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| GPU-001 | SurfaceFlinger.cpp | dumpAllLocked() | ~8500-8700 | COND, STR | Easy | GpuWorkDumpsysTest |
| GPU-002 | SurfaceFlinger.cpp | getGpuContextPriority() | ~2100-2150 | COND, ERR | Easy | GpuWorkDumpsysTest |
| GPU-003 | SurfaceFlinger.cpp | onMessageReceived() | ~2300-2500 | STATE, SYNC | Medium | GpuWorkDumpsysTest |
| GPU-004 | DisplayDevice.cpp | getPowerMode() | 195-200 | COND | Easy | GpuWorkDumpsysTest |

### 2. GPU Profiling（GPU 分析追蹤）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| GPU-005 | FrameTracer.cpp | traceNewLayer() | 47-55 | COND, STATE | Easy | CtsGpuProfilingDataTest |
| GPU-006 | FrameTracer.cpp | traceTimestamp() | 57-73 | COND, SYNC | Medium | CtsGpuProfilingDataTest |
| GPU-007 | FrameTracer.cpp | traceFence() | 75-98 | COND, BOUND | Medium | CtsGpuProfilingDataTest |
| GPU-008 | FrameTracer.cpp | tracePendingFencesLocked() | 100-125 | BOUND, STATE | Medium | CtsGpuProfilingDataTest |
| GPU-009 | FrameTracer.cpp | traceLocked() | 127-145 | COND, CALC | Easy | CtsGpuProfilingDataTest |
| GPU-010 | FrameTracer.cpp | traceSpanLocked() | 147-157 | CALC, BOUND | Medium | CtsGpuProfilingDataTest |

### 3. Display Mode（顯示模式管理）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| GPU-011 | DisplayDevice.cpp | setPowerMode() | 168-182 | STATE, COND | Medium | BootDisplayModeTest |
| GPU-012 | DisplayDevice.cpp | setDisplayName() | 118-124 | COND, STR | Easy | BootDisplayModeTest |
| GPU-013 | DisplayDevice.cpp | getWidth()/getHeight() | 114-116 | CALC | Easy | BootDisplayModeTest |
| GPU-014 | DisplayDevice.cpp | getFrontEndInfo() | 126-164 | CALC, STATE | Hard | BootDisplayModeTest |
| GPU-015 | RefreshRateSelector.cpp | constructKnownFrameRates() | 65-78 | BOUND, CALC | Medium | BootDisplayModeTest |
| GPU-016 | RefreshRateSelector.cpp | sortByRefreshRate() | 80-95 | COND, CALC | Medium | BootDisplayModeTest |
| GPU-017 | RefreshRateSelector.cpp | divisorRange() | 97-115 | CALC, BOUND | Hard | BootDisplayModeTest |

### 4. VSync & Scheduler（垂直同步與調度）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| GPU-018 | VsyncModulator.cpp | setTransactionSchedule() | 47-77 | STATE, COND | Medium | BootDisplayModeTest |
| GPU-019 | VsyncModulator.cpp | onTransactionCommit() | 79-84 | STATE, COND | Easy | BootDisplayModeTest |
| GPU-020 | VsyncModulator.cpp | onRefreshRateChangeInitiated() | 86-91 | STATE | Easy | BootDisplayModeTest |
| GPU-021 | VsyncModulator.cpp | onRefreshRateChangeCompleted() | 93-98 | STATE | Easy | BootDisplayModeTest |
| GPU-022 | VsyncModulator.cpp | onDisplayRefresh() | 100-117 | COND, CALC | Medium | BootDisplayModeTest |
| GPU-023 | VsyncModulator.cpp | getNextVsyncConfigType() | 124-135 | COND, STATE | Medium | BootDisplayModeTest |

### 5. FPS Reporting（FPS 報告）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| GPU-024 | FpsReporter.cpp | dispatchLayerFps() | 30-84 | COND, SYNC | Hard | CtsGpuProfilingDataTest |
| GPU-025 | FpsReporter.cpp | addListener() | 93-97 | RES, ERR | Easy | CtsGpuProfilingDataTest |
| GPU-026 | FpsReporter.cpp | removeListener() | 99-102 | RES | Easy | CtsGpuProfilingDataTest |

### 6. HWComposer（硬體合成器）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| GPU-027 | HWComposer.cpp | getDisplayIdentificationData() | 103-114 | COND, ERR | Medium | BootDisplayModeTest |
| GPU-028 | HWComposer.cpp | hasCapability() | 116-118 | COND | Easy | BootDisplayModeTest |
| GPU-029 | HWComposer.cpp | hasDisplayCapability() | 120-123 | COND, BOUND | Medium | BootDisplayModeTest |
| GPU-030 | HWComposer.cpp | onHotplug() | 125-135 | STATE, COND | Hard | BootDisplayModeTest |

### 7. Region Sampling（區域採樣）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| GPU-031 | RegionSamplingThread.cpp | EnvironmentTimingTunables() | 61-82 | CALC, BOUND | Medium | CtsGpuProfilingDataTest |
| GPU-032 | RegionSamplingThread.cpp | toNsString() | 55-58 | CALC, STR | Hard | CtsGpuProfilingDataTest |

---

## 注入類型說明

| 標籤 | 說明 | 常見 Bug 模式 |
|------|------|--------------|
| `COND` | 條件判斷 | if/else 邏輯錯誤、比較運算符錯誤（< vs <=） |
| `BOUND` | 邊界檢查 | 陣列越界、null 檢查遺漏、範圍驗證錯誤 |
| `RES` | 資源管理 | 忘記釋放資源、重複釋放、使用已釋放資源 |
| `STATE` | 狀態轉換 | 狀態機轉換錯誤、flag 設定遺漏 |
| `CALC` | 數值計算 | 運算符錯誤、單位轉換錯誤、溢位 |
| `STR` | 字串處理 | 格式化錯誤、解析錯誤 |
| `SYNC` | 同步問題 | 鎖順序錯誤、競態條件 |
| `ERR` | 錯誤處理 | 錯誤碼檢查遺漏、異常處理不當 |

---

## 難度分布統計

| 難度 | 數量 | 百分比 | 特徵 |
|------|------|--------|------|
| Easy | 12 | 38% | 單一檔案、單一明顯錯誤 |
| Medium | 14 | 44% | 跨函數邏輯、需要追蹤呼叫鏈 |
| Hard | 6 | 18% | 跨模組架構、需理解系統設計 |

---

## 推薦出題優先順序

### 高優先級（核心功能）
1. **GPU-011** - `setPowerMode()` - 電源模式控制，影響顯示開關
2. **GPU-018** - `setTransactionSchedule()` - 交易調度，影響渲染時機
3. **GPU-005** - `traceNewLayer()` - 圖層追蹤，影響 Profiling 數據
4. **GPU-015** - `constructKnownFrameRates()` - 刷新率列表，影響模式選擇

### 中優先級（重要功能）
5. **GPU-024** - `dispatchLayerFps()` - FPS 分發，複雜度高
6. **GPU-027** - `getDisplayIdentificationData()` - 顯示識別
7. **GPU-006** - `traceTimestamp()` - 時間戳追蹤

### 低優先級（輔助功能）
8. **GPU-012** - `setDisplayName()` - 顯示名稱設定
9. **GPU-025/026** - Listener 管理

---

## 相關 CTS 模組

| CTS 模組名稱 | 測試數量 | 備註 |
|-------------|---------|------|
| CtsGraphicsTestCases | 多個 | 主要 graphics 測試 |
| CtsGraphicsHostTestCases | 7+ | Host 端測試（本清單涵蓋）|
| CtsSurfaceControlTestCases | 多個 | SurfaceControl 相關 |

---

## 版本資訊

**版本**: v1.0.0  
**建立日期**: 2026-02-10  
**更新時間**: 2026-02-10 18:30 GMT+8  

### 變更記錄
- v1.0.0 (2026-02-10): 初版建立，涵蓋 32 個注入點
