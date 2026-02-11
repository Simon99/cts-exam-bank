# Acceleration 模組注入點分布列表

**CTS 路徑**: `cts/tests/acceleration/`  
**更新時間**: 2026-02-10 18:35 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 18 |
| Easy | 8 (44%) |
| Medium | 7 (39%) |
| Hard | 3 (17%) |

**涵蓋測試類別**：Hardware Acceleration、Software Acceleration、Window Flag Acceleration

## CTS 測試類別

### 硬體加速測試
| 測試類別 | 檔案 | 描述 | 優先級 |
|---------|------|------|--------|
| HardwareAccelerationTest | `HardwareAccelerationTest.java` | 驗證硬體加速開啟時的 View 狀態 | 高 |
| SoftwareAccelerationTest | `SoftwareAccelerationTest.java` | 驗證軟體加速時的 View 狀態 | 高 |
| WindowFlagHardwareAccelerationTest | `WindowFlagHardwareAccelerationTest.java` | Window Flag 控制加速行為 | 中 |
| BaseAccelerationTest | `BaseAccelerationTest.java` | 基礎測試類別、GL ES 版本檢測 | 高 |

**測試重點**：
- `View.isHardwareAccelerated()` 返回值正確性
- `View.isCanvasHardwareAccelerated()` 返回值正確性
- GL ES 版本與硬體加速支援關係
- `setLayerType()` 對加速行為的影響

## 對應 AOSP 源碼路徑

### Java 層（Framework Graphics）
```
frameworks/base/graphics/java/android/graphics/
├── HardwareRenderer.java         # 硬體渲染器核心
├── HardwareRendererObserver.java # 渲染觀察者
├── HardwareBufferRenderer.java   # 硬體緩衝渲染
├── RenderNode.java               # 渲染節點
└── Canvas.java                   # 畫布
```

### Java 層（Framework View）
```
frameworks/base/core/java/android/view/
├── ThreadedRenderer.java         # 線程渲染器
├── View.java                     # View 基類（isHardwareAccelerated）
├── ViewRootImpl.java             # View 根實現
├── RenderNodeAnimator.java       # 渲染節點動畫
└── HdrRenderState.java           # HDR 渲染狀態
```

### Native 層
```
frameworks/base/libs/hwui/
├── RenderNode.cpp
├── RenderProxy.cpp
├── CanvasContext.cpp
└── ThreadBase.cpp
```

---

## 注入點清單

### 1. HardwareRenderer（硬體渲染器）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| ACC-001 | HardwareRenderer.java | SYNC_OK / SYNC_REDRAW_REQUESTED 常數 | 76-90 | COND | Easy | HardwareAccelerationTest |
| ACC-002 | HardwareRenderer.java | syncAndDrawFrame() | ~200-250 | STATE, COND | Medium | HardwareAccelerationTest |
| ACC-003 | HardwareRenderer.java | setSurface() | ~300-350 | RES, STATE | Medium | HardwareAccelerationTest |
| ACC-004 | HardwareRenderer.java | setLightSourceGeometry() | ~400-420 | CALC, BOUND | Easy | HardwareAccelerationTest |
| ACC-005 | HardwareRenderer.java | setLightSourceAlpha() | ~430-450 | CALC, BOUND | Easy | HardwareAccelerationTest |

### 2. HardwareBufferRenderer（硬體緩衝渲染）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| ACC-006 | HardwareBufferRenderer.java | setContentRoot() | 90-97 | STATE | Easy | HardwareAccelerationTest |
| ACC-007 | HardwareBufferRenderer.java | isClosed() | 116-118 | STATE | Easy | HardwareAccelerationTest |
| ACC-008 | HardwareBufferRenderer.java | close() | 125-133 | RES, ERR | Medium | HardwareAccelerationTest |
| ACC-009 | HardwareBufferRenderer.java | RenderRequest.draw() | 245-270 | COND, STATE | Medium | HardwareAccelerationTest |
| ACC-010 | HardwareBufferRenderer.java | setBufferTransform() | 305-320 | COND, BOUND | Medium | HardwareAccelerationTest |

### 3. ThreadedRenderer（線程渲染器）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| ACC-011 | ThreadedRenderer.java | PROFILE_PROPERTY 常數 | 67-72 | STR | Easy | HardwareAccelerationTest |
| ACC-012 | ThreadedRenderer.java | create() | ~150-200 | COND, RES | Hard | HardwareAccelerationTest |
| ACC-013 | ThreadedRenderer.java | initialize() | ~220-280 | STATE, RES | Hard | HardwareAccelerationTest |
| ACC-014 | ThreadedRenderer.java | updateSurface() | ~350-400 | STATE, COND | Medium | HardwareAccelerationTest |

### 4. View 硬體加速狀態

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| ACC-015 | View.java | isHardwareAccelerated() | ~22000 | COND | Easy | HardwareAccelerationTest |
| ACC-016 | View.java | setLayerType() | ~22100-22200 | STATE, COND | Medium | HardwareAccelerationTest |
| ACC-017 | View.java | getLayerType() | ~22050 | STATE | Easy | SoftwareAccelerationTest |

### 5. GL ES 版本檢測

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|---------|----------|------|---------------|
| ACC-018 | BaseAccelerationTest.java | getGlEsVersion() / getMajorVersion() | 62-72 | CALC, COND | Hard | HardwareAccelerationTest |

---

## 注入類型說明

| 標籤 | 說明 | 常見 Bug 模式 |
|------|------|--------------|
| `COND` | 條件判斷 | if/else 邏輯錯誤、GL ES 版本比較錯誤 |
| `BOUND` | 邊界檢查 | alpha 值範圍檢查、座標驗證 |
| `RES` | 資源管理 | Surface 釋放、Renderer 生命週期 |
| `STATE` | 狀態轉換 | 加速狀態切換、Layer Type 狀態 |
| `CALC` | 數值計算 | 光源位置計算、版本號解析 |
| `STR` | 字串處理 | Property 解析 |
| `ERR` | 錯誤處理 | 關閉後操作處理 |

---

## 難度分布統計

| 難度 | 數量 | 百分比 | 特徵 |
|------|------|--------|------|
| Easy | 8 | 44% | 單一檔案、狀態查詢、簡單條件 |
| Medium | 7 | 39% | 跨函數邏輯、資源管理 |
| Hard | 3 | 17% | 渲染器初始化、GL 版本解析 |

---

## 推薦出題優先順序

### 高優先級（核心功能）
1. **ACC-015** - `isHardwareAccelerated()` - 核心 API，CTS 直接測試
2. **ACC-016** - `setLayerType()` - Layer 類型設定，影響加速行為
3. **ACC-002** - `syncAndDrawFrame()` - 同步繪製，核心渲染流程
4. **ACC-018** - GL ES 版本檢測 - 影響整體加速決策

### 中優先級（重要功能）
5. **ACC-008** - `close()` - 資源釋放
6. **ACC-009** - `RenderRequest.draw()` - 渲染請求
7. **ACC-012** - ThreadedRenderer 創建

### 低優先級（輔助功能）
8. **ACC-004/005** - 光源設定
9. **ACC-011** - Profile 屬性

---

## 相關 CTS 模組

| CTS 模組名稱 | 測試數量 | 備註 |
|-------------|---------|------|
| CtsAccelerationTestCases | 4+ | 主要加速測試 |
| CtsViewTestCases | 多個 | View 相關測試 |
| CtsGraphicsTestCases | 多個 | 圖形相關測試 |

---

## 版本資訊

**版本**: v1.0.0  
**建立日期**: 2026-02-10  
**更新時間**: 2026-02-10 18:35 GMT+8  

### 變更記錄
- v1.0.0 (2026-02-10): 初版建立，涵蓋 18 個注入點
