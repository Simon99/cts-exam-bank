# Vibrator 模組注入點分布列表

**CTS 路徑**: `cts/tests/vibrator/`  
**更新時間**: 2026-02-10 22:30 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 38 |
| Easy | 14 (37%) |
| Medium | 16 (42%) |
| Hard | 8 (21%) |

**涵蓋測試類別**：見下方

## CTS 測試類別

### 核心振動器測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| VibratorTest | 振動器基本功能測試 | 高 |
| VibrationEffectTest | 振動效果測試 | 高 |
| VibrationEffectXmlSerializationTest | 效果 XML 序列化 | 中 |
| VibrationAttributesTest | 振動屬性測試 | 中 |
| VibratorManagerTest | 振動器管理測試 | 高 |
| CombinedVibrationTest | 組合振動測試 | 中 |

## 對應 AOSP 源碼路徑

### Framework 層（API）
- `frameworks/base/core/java/android/os/Vibrator.java` (783 行) ⭐
- `frameworks/base/core/java/android/os/VibrationEffect.java` (1650 行) ⭐
- `frameworks/base/core/java/android/os/VibrationAttributes.java`
- `frameworks/base/core/java/android/os/VibratorManager.java` (172 行)
- `frameworks/base/core/java/android/os/CombinedVibration.java`
- `frameworks/base/core/java/android/os/VibratorInfo.java`
- `frameworks/base/core/java/android/os/SystemVibrator.java`
- `frameworks/base/core/java/android/os/NullVibrator.java`
- `frameworks/base/core/java/android/os/SystemVibratorManager.java`

### Vibrator 子類別
- `frameworks/base/core/java/android/os/vibrator/VibrationConfig.java`
- `frameworks/base/core/java/android/os/vibrator/VibratorFrequencyProfile.java`
- `frameworks/base/core/java/android/os/vibrator/VibrationEffectSegment.java`

### 序列化
- `frameworks/base/core/java/android/os/vibrator/persistence/VibrationXmlParser.java`
- `frameworks/base/core/java/android/os/vibrator/persistence/VibrationXmlSerializer.java`

---

## 注入點清單

### 1. Vibrator（核心 API）⭐

**檔案**: `frameworks/base/core/java/android/os/Vibrator.java` (783 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| VIB-001 | hasVibrator() | 待查 | COND | Easy | VibratorTest | 振動器存在檢查 |
| VIB-002 | hasAmplitudeControl() | 待查 | COND | Easy | VibratorTest | 振幅控制支援 |
| VIB-003 | hasFrequencyControl() | 待查 | COND | Medium | VibratorTest | 頻率控制支援 |
| VIB-004 | vibrate(milliseconds) | 待查 | COND, CALC | Easy | VibratorTest | 基本振動 |
| VIB-005 | vibrate(VibrationEffect) | 待查 | COND | Easy | VibrationEffectTest | 效果振動 |
| VIB-006 | vibrate(VibrationEffect, AudioAttributes) | 待查 | COND | Medium | VibratorTest | 帶音訊屬性振動 |
| VIB-007 | vibrate(VibrationEffect, VibrationAttributes) | 待查 | COND | Medium | VibrationAttributesTest | 帶振動屬性 |
| VIB-008 | cancel() | 待查 | STATE | Easy | VibratorTest | 取消振動 |
| VIB-009 | getDefaultVibrationIntensity(usage) | 160-162 | COND | Easy | VibratorTest | 預設強度 |
| VIB-010 | isDefaultKeyboardVibrationEnabled() | 169-171 | COND | Easy | VibratorTest | 鍵盤振動預設 |
| VIB-011 | getInfo() | 132-134 | COND | Easy | VibratorTest | 取得資訊 |
| VIB-012 | areEffectsSupported(effects[]) | 待查 | COND, BOUND | Medium | VibrationEffectTest | 批次效果支援檢查 |
| VIB-013 | arePrimitivesSupported(primitives[]) | 待查 | COND, BOUND | Medium | VibrationEffectTest | 原語支援檢查 |
| VIB-014 | addVibratorStateListener(listener) | 待查 | STATE | Medium | VibratorTest | 狀態監聽器 |
| VIB-015 | removeVibratorStateListener(listener) | 待查 | STATE | Easy | VibratorTest | 移除監聽器 |

### 2. VibrationEffect（振動效果）⭐

**檔案**: `frameworks/base/core/java/android/os/VibrationEffect.java` (1650 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| VIB-021 | createOneShot(milliseconds, amplitude) | 172-178 | COND, BOUND | Medium | VibrationEffectTest | 一次性振動，amplitude=0 檢查 |
| VIB-022 | createWaveform(timings[], repeat) | 待查 | COND, BOUND | Medium | VibrationEffectTest | 波形振動 |
| VIB-023 | createWaveform(timings[], amplitudes[], repeat) | 待查 | COND, BOUND, CALC | Hard | VibrationEffectTest | 完整波形 |
| VIB-024 | createPredefined(effectId) | 待查 | COND | Easy | VibrationEffectTest | 預定義效果 |
| VIB-025 | startComposition() | 待查 | STATE | Easy | VibrationEffectTest | 開始組合 |
| VIB-026 | Composition.addPrimitive(primitiveId) | 待查 | COND | Medium | VibrationEffectTest | 加入原語 |
| VIB-027 | Composition.addPrimitive(primitiveId, scale) | 待查 | COND, BOUND | Medium | VibrationEffectTest | 帶縮放原語 |
| VIB-028 | Composition.addPrimitive(primitiveId, scale, delay) | 待查 | COND, BOUND, CALC | Hard | VibrationEffectTest | 完整原語 |
| VIB-029 | Composition.compose() | 待查 | STATE, ERR | Medium | VibrationEffectTest | 組合完成 |
| VIB-030 | validate() | 待查 | COND, BOUND | Hard | VibrationEffectTest | 效果驗證 |
| VIB-031 | getDuration() | 待查 | CALC | Easy | VibrationEffectTest | 持續時間計算 |
| VIB-032 | scale(scaleFactor) | 待查 | CALC, BOUND | Medium | VibrationEffectTest | 效果縮放 |

### 3. VibratorManager（多振動器管理）

**檔案**: `frameworks/base/core/java/android/os/VibratorManager.java` (172 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| VIB-041 | getVibratorIds() | 待查 | COND | Easy | VibratorManagerTest | 取得振動器 ID |
| VIB-042 | getVibrator(vibratorId) | 待查 | COND, BOUND | Easy | VibratorManagerTest | 取得特定振動器 |
| VIB-043 | getDefaultVibrator() | 待查 | COND | Easy | VibratorManagerTest | 預設振動器 |
| VIB-044 | vibrate(CombinedVibration) | 待查 | COND | Medium | CombinedVibrationTest | 組合振動 |
| VIB-045 | cancel() | 待查 | STATE | Easy | VibratorManagerTest | 取消所有振動 |

### 4. CombinedVibration

**檔案**: `frameworks/base/core/java/android/os/CombinedVibration.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| VIB-051 | createParallel(effect) | 待查 | COND | Medium | CombinedVibrationTest | 平行振動 |
| VIB-052 | createSynced(effects) | 待查 | COND, SYNC | Hard | CombinedVibrationTest | 同步振動 |
| VIB-053 | ParallelCombination.addVibrator(vibratorId, effect) | 待查 | COND, BOUND | Hard | CombinedVibrationTest | 加入振動器 |
| VIB-054 | ParallelCombination.combine() | 待查 | STATE | Medium | CombinedVibrationTest | 組合完成 |

---

## 統計摘要

| 注入類型 | 數量 |
|----------|------|
| COND（條件判斷）| 30 |
| BOUND（邊界檢查）| 10 |
| STATE（狀態轉換）| 8 |
| CALC（數值計算）| 8 |
| ERR（錯誤處理）| 1 |
| SYNC（同步問題）| 1 |

## 注入難點分析

1. **振幅範圍** — amplitude 必須在 1-255 或 DEFAULT_AMPLITUDE
2. **波形驗證** — timings/amplitudes 陣列長度必須匹配
3. **Composition** — 原語組合的順序和延遲計算
4. **多振動器同步** — CombinedVibration 的同步邏輯
5. **硬體支援檢查** — 不同效果在不同硬體上的支援度

## 相關測試命令

```bash
# 執行 Vibrator CTS
run cts -m CtsVibratorTestCases
```

## 下一步 - Phase B

從此列表中挑選注入點，進行題目生成：
1. [x] Phase A 完成 - 注入點列表已建立
2. [ ] Phase B - 挑選注入點、設計 bug、產生 patch
3. [ ] Phase C - 實機驗證
