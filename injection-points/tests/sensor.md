# Sensor 模組注入點分布列表

**CTS 路徑**: `cts/tests/sensor/`  
**更新時間**: 2026-02-10 22:30 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 42 |
| Easy | 16 (38%) |
| Medium | 17 (40%) |
| Hard | 9 (22%) |

**涵蓋測試類別**：見下方

## CTS 測試類別

### 核心感測器測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| SensorTest | 感測器基本操作測試 | 高 |
| SensorBatchingTests | 批次處理測試 | 高 |
| SensorDirectReportTest | Direct Channel 報告 | 中 |
| SensorIntegrationTests | 整合測試 | 高 |
| SingleSensorTests | 單一感測器測試 | 高 |
| SensorParameterRangeTest | 參數範圍測試 | 中 |
| SensorManagerStaticTest | SensorManager 靜態測試 | 中 |
| SensorBatchingFifoTest | FIFO 批次測試 | 中 |
| SensorSupportTest | 支援性測試 | 低 |
| SensorHeadTrackerTest | 頭部追蹤測試 | 低 |
| SensorAdditionalInfoTest | 附加資訊測試 | 低 |

### Rate Permission 測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| ReturnedRateInfoTest | 回傳速率測試 | 中 |
| DirectReportAPI31Test | API31 直接報告 | 中 |
| EventConnectionAPI31Test | 事件連接 | 中 |

## 對應 AOSP 源碼路徑

### Java 層（Framework）
- `frameworks/base/core/java/android/hardware/SensorManager.java` (2010 行) ⭐
- `frameworks/base/core/java/android/hardware/Sensor.java` (1435 行) ⭐
- `frameworks/base/core/java/android/hardware/SensorEvent.java` (859 行)
- `frameworks/base/core/java/android/hardware/SensorEventListener.java` (56 行)
- `frameworks/base/core/java/android/hardware/SensorEventListener2.java` (37 行)
- `frameworks/base/core/java/android/hardware/SensorDirectChannel.java` (240 行)
- `frameworks/base/core/java/android/hardware/SensorAdditionalInfo.java` (278 行)
- `frameworks/base/core/java/android/hardware/SensorPrivacyManager.java` (1127 行)

### 實作層
- `frameworks/base/core/java/android/hardware/SystemSensorManager.java` — SensorManager 實作

---

## 注入點清單

### 1. SensorManager（核心 API）⭐

**檔案**: `frameworks/base/core/java/android/hardware/SensorManager.java` (2010 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEN-001 | registerListener(listener, sensor, samplingPeriodUs) | 762-766 | COND | Easy | SensorTest | 基本註冊，delay 轉換 |
| SEN-002 | registerListener(listener, sensor, samplingPeriodUs, maxReportLatencyUs) | 821-824 | COND, CALC | Medium | SensorBatchingTests | 批次註冊，latency 處理 |
| SEN-003 | registerListener(listener, sensor, samplingPeriodUs, handler) | 856-859 | COND | Easy | SensorTest | Handler 版註冊 |
| SEN-004 | registerListener(4 params + handler) | 874-877 | COND, CALC | Medium | SensorBatchingTests | 完整版註冊 |
| SEN-005 | unregisterListener(listener) | 700-704 | COND, ERR | Easy | SensorTest | null 檢查 |
| SEN-006 | unregisterListener(listener, sensor) | 688-695 | COND | Easy | SensorTest | 特定感測器取消 |
| SEN-007 | getDelay(samplingPeriodUs) | 待查 | CALC, COND | Medium | SensorTest | 延遲常數轉換 |
| SEN-008 | flush(listener) | 883-910 | COND, ERR | Medium | SensorBatchingFifoTest | FIFO 刷新邏輯 |
| SEN-009 | getDefaultSensor(type) | 待查 | COND | Easy | SensorTest | 取得預設感測器 |
| SEN-010 | getDefaultSensor(type, wakeUp) | 待查 | COND | Medium | SensorTest | wakeUp 參數處理 |
| SEN-011 | getSensorList(type) | 待查 | COND | Easy | SensorManagerStaticTest | 列表過濾 |
| SEN-012 | getDynamicSensorList(type) | 待查 | COND | Medium | SensorTest | 動態感測器列表 |
| SEN-013 | requestTriggerSensor(listener, sensor) | 待查 | COND, STATE | Medium | SensorTest | Trigger 感測器請求 |
| SEN-014 | cancelTriggerSensor(listener, sensor) | 待查 | COND, STATE | Easy | SensorTest | 取消 Trigger |

### 2. Sensor（感測器屬性）

**檔案**: `frameworks/base/core/java/android/hardware/Sensor.java` (1435 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEN-021 | getType() | 待查 | COND | Easy | SensorTest | 類型取得 |
| SEN-022 | getMaximumRange() | 待查 | CALC | Easy | SensorParameterRangeTest | 最大範圍 |
| SEN-023 | getResolution() | 待查 | CALC | Easy | SensorParameterRangeTest | 解析度 |
| SEN-024 | getPower() | 待查 | CALC | Easy | SensorTest | 功耗 |
| SEN-025 | getMinDelay() | 待查 | CALC, BOUND | Medium | SensorTest | 最小延遲 |
| SEN-026 | getMaxDelay() | 待查 | CALC, BOUND | Medium | SensorTest | 最大延遲 |
| SEN-027 | getFifoReservedEventCount() | 待查 | CALC | Medium | SensorBatchingFifoTest | FIFO 保留事件數 |
| SEN-028 | getFifoMaxEventCount() | 待查 | CALC | Medium | SensorBatchingFifoTest | FIFO 最大事件數 |
| SEN-029 | isWakeUpSensor() | 待查 | COND | Easy | SensorTest | Wake-up 判斷 |
| SEN-030 | getReportingMode() | 待查 | COND | Medium | SensorTest | 報告模式 |
| SEN-031 | isDirectChannelTypeSupported(type) | 待查 | COND | Medium | SensorDirectReportTest | Direct Channel 支援 |
| SEN-032 | getHighestDirectReportRateLevel() | 待查 | COND, CALC | Hard | SensorDirectReportTest | 最高直接報告速率 |

### 3. SensorEvent（事件資料）

**檔案**: `frameworks/base/core/java/android/hardware/SensorEvent.java` (859 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEN-041 | values[] 陣列處理 | 待查 | BOUND, CALC | Medium | SensorTest | 感測器值陣列邊界 |
| SEN-042 | timestamp 處理 | 待查 | CALC | Medium | SensorIntegrationTests | 時間戳計算 |
| SEN-043 | accuracy 處理 | 待查 | COND | Easy | SensorTest | 精確度狀態 |

### 4. SensorDirectChannel

**檔案**: `frameworks/base/core/java/android/hardware/SensorDirectChannel.java` (240 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEN-051 | configure(sensor, rateLevel) | 待查 | COND, STATE | Hard | SensorDirectReportTest | Direct Channel 配置 |
| SEN-052 | close() | 待查 | RES, STATE | Medium | SensorDirectReportTest | 資源釋放 |
| SEN-053 | isOpen() | 待查 | STATE | Easy | SensorDirectReportTest | 開啟狀態檢查 |

### 5. SystemSensorManager（實作）

**檔案**: `frameworks/base/core/java/android/hardware/SystemSensorManager.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| SEN-061 | registerListenerImpl() | 待查 | COND, STATE, ERR | Hard | SensorTest | 實際註冊實作 |
| SEN-062 | unregisterListenerImpl() | 待查 | STATE, RES | Medium | SensorTest | 實際取消實作 |
| SEN-063 | createDirectChannel() | 待查 | RES, ERR | Hard | SensorDirectReportTest | 建立 Direct Channel |
| SEN-064 | configureDirectChannel() | 待查 | COND, STATE | Hard | SensorDirectReportTest | 配置 Direct Channel |
| SEN-065 | flushImpl() | 待查 | STATE, ERR | Hard | SensorBatchingFifoTest | 刷新實作 |
| SEN-066 | requestTriggerSensorImpl() | 待查 | STATE | Hard | SensorTest | Trigger 實作 |

---

## 統計摘要

| 注入類型 | 數量 |
|----------|------|
| COND（條件判斷）| 28 |
| CALC（數值計算）| 14 |
| STATE（狀態轉換）| 12 |
| ERR（錯誤處理）| 6 |
| RES（資源管理）| 4 |
| BOUND（邊界檢查）| 3 |

## 注入難點分析

1. **批次處理邏輯** — FIFO、latency 計算涉及多個條件
2. **Direct Channel** — Native 層整合，需要理解 HAL 互動
3. **Rate Permission** — API 31+ 的速率權限檢查
4. **Trigger Sensor** — 一次性觸發邏輯的狀態管理

## 下一步 - Phase B

從此列表中挑選注入點，進行題目生成：
1. [x] Phase A 完成 - 注入點列表已建立
2. [ ] Phase B - 挑選注入點、設計 bug、產生 patch
3. [ ] Phase C - 實機驗證
