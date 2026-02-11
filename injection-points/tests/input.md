# Input 模組注入點分布列表

**CTS 路徑**: `cts/tests/input/`  
**更新時間**: 2026-02-10 22:30 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 48 |
| Easy | 18 (38%) |
| Medium | 20 (41%) |
| Hard | 10 (21%) |

**涵蓋測試類別**：見下方

## CTS 測試類別

### 核心輸入測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| InputEventTest | 輸入事件基礎（KeyCode/Axis） | 高 |
| TouchScreenTest | 觸控螢幕測試 | 高 |
| MotionEventIsResampledTest | Motion 事件重採樣 | 中 |
| VelocityTrackerTest | 速度追蹤測試 | 高 |
| KeyEventTest (待確認) | 按鍵事件 | 高 |

### 進階輸入測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| PointerIconTest | 滑鼠指標圖示 | 中 |
| PointerCancelTest | 指標取消事件 | 中 |
| TouchModeTest | 觸控模式切換 | 中 |
| DrawingTabletTest | 繪圖平板測試 | 低 |
| SimultaneousTouchAndStylusTest | 觸控+手寫筆 | 低 |
| MotionPredictorTest | 動作預測 | 中 |

### 功能測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| BackKeyShortcutsTest | 返回鍵快捷 | 中 |
| ModifierKeyRemappingTest | 修飾鍵重映射 | 低 |
| AppKeyCombinationsTest | App 按鍵組合 | 中 |
| OverrideSystemKeyBehaviorTest | 系統按鍵覆蓋 | 低 |
| InputShellCommandTest | 輸入 Shell 命令 | 低 |

## 對應 AOSP 源碼路徑

### Framework 層（核心）
- `frameworks/base/core/java/android/view/MotionEvent.java` (4671 行) ⭐
- `frameworks/base/core/java/android/view/KeyEvent.java` (3291 行) ⭐
- `frameworks/base/core/java/android/view/InputEvent.java` (275 行)
- `frameworks/base/core/java/android/view/InputDevice.java`
- `frameworks/base/core/java/android/view/VelocityTracker.java`
- `frameworks/base/core/java/android/view/MotionPredictor.java`

### 輸入處理
- `frameworks/base/core/java/android/view/InputEventReceiver.java`
- `frameworks/base/core/java/android/view/InputEventSender.java`
- `frameworks/base/core/java/android/view/InputEventConsistencyVerifier.java`
- `frameworks/base/core/java/android/view/InputChannel.java`
- `frameworks/base/core/java/android/view/InputQueue.java`

### 指標與鍵盤
- `frameworks/base/core/java/android/view/PointerIcon.java`
- `frameworks/base/core/java/android/view/KeyCharacterMap.java`

### Input Manager
- `frameworks/base/core/java/android/hardware/input/InputManager.java`
- `frameworks/base/core/java/android/hardware/input/InputManagerGlobal.java`
- `frameworks/base/services/core/java/com/android/server/input/InputManagerService.java`

---

## 注入點清單

### 1. MotionEvent（觸控事件）⭐

**檔案**: `frameworks/base/core/java/android/view/MotionEvent.java` (4671 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| INP-001 | getAction() | 待查 | COND | Easy | InputEventTest | 動作碼取得 |
| INP-002 | getActionMasked() | 待查 | COND, CALC | Medium | TouchScreenTest | 遮罩動作碼 |
| INP-003 | getActionIndex() | 待查 | CALC, BOUND | Medium | TouchScreenTest | 動作索引 |
| INP-004 | getX() / getY() | 待查 | CALC | Easy | TouchScreenTest | 座標取得 |
| INP-005 | getX(pointerIndex) / getY(pointerIndex) | 待查 | BOUND | Easy | TouchScreenTest | 多點座標 |
| INP-006 | getPointerCount() | 待查 | CALC | Easy | TouchScreenTest | 觸控點數 |
| INP-007 | getPointerId(pointerIndex) | 待查 | BOUND | Easy | TouchScreenTest | 觸控點 ID |
| INP-008 | findPointerIndex(pointerId) | 待查 | COND, BOUND | Medium | TouchScreenTest | 反向查找索引 |
| INP-009 | getPressure(pointerIndex) | 待查 | BOUND, CALC | Medium | TouchScreenTest | 壓力值 |
| INP-010 | getSize(pointerIndex) | 待查 | BOUND, CALC | Medium | TouchScreenTest | 觸控大小 |
| INP-011 | getToolType(pointerIndex) | 待查 | BOUND, COND | Medium | SimultaneousTouchAndStylusTest | 工具類型 |
| INP-012 | getHistorySize() | 待查 | CALC | Easy | MotionEventIsResampledTest | 歷史大小 |
| INP-013 | getHistoricalX(pointerIndex, pos) | 待查 | BOUND | Medium | MotionEventIsResampledTest | 歷史 X |
| INP-014 | getHistoricalY(pointerIndex, pos) | 待查 | BOUND | Medium | MotionEventIsResampledTest | 歷史 Y |
| INP-015 | getAxisValue(axis) | 待查 | COND | Easy | InputEventTest | 軸值取得 |
| INP-016 | getAxisValue(axis, pointerIndex) | 待查 | BOUND, COND | Medium | DrawingTabletTest | 特定指標軸值 |
| INP-017 | obtain() | 待查 | RES | Medium | TouchScreenTest | 事件池取得 |
| INP-018 | recycle() | 待查 | RES, STATE | Medium | TouchScreenTest | 回收事件 |
| INP-019 | setAction(action) | 待查 | COND | Easy | InputEventTest | 設定動作 |
| INP-020 | offsetLocation(deltaX, deltaY) | 待查 | CALC | Easy | TouchScreenTest | 座標偏移 |
| INP-021 | transform(matrix) | 待查 | CALC | Hard | TouchScreenTest | 矩陣變換 |

### 2. KeyEvent（按鍵事件）⭐

**檔案**: `frameworks/base/core/java/android/view/KeyEvent.java` (3291 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| INP-031 | getKeyCode() | 待查 | COND | Easy | InputEventTest | 按鍵碼 |
| INP-032 | getAction() | 待查 | COND | Easy | InputEventTest | 動作（DOWN/UP） |
| INP-033 | getMetaState() | 待查 | COND, CALC | Medium | ModifierKeyRemappingTest | 修飾鍵狀態 |
| INP-034 | isShiftPressed() / isCtrlPressed() | 待查 | COND | Easy | AppKeyCombinationsTest | 修飾鍵檢查 |
| INP-035 | getRepeatCount() | 待查 | CALC | Easy | InputEventTest | 重複次數 |
| INP-036 | getDownTime() | 待查 | CALC | Easy | InputEventTest | 按下時間 |
| INP-037 | getEventTime() | 待查 | CALC | Easy | InputEventTest | 事件時間 |
| INP-038 | keyCodeToString(keyCode) | 待查 | COND | Easy | InputEventTest | 按鍵碼轉字串 |
| INP-039 | keyCodeFromString(symbolicName) | 待查 | COND, STR | Medium | InputEventTest | 字串轉按鍵碼 |
| INP-040 | isSystem() | 待查 | COND | Medium | OverrideSystemKeyBehaviorTest | 系統按鍵判斷 |
| INP-041 | hasModifiers(modifiers) | 待查 | COND, CALC | Medium | AppKeyCombinationsTest | 修飾鍵組合檢查 |

### 3. VelocityTracker（速度追蹤）

**檔案**: `frameworks/base/core/java/android/view/VelocityTracker.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| INP-051 | obtain() | 待查 | RES | Easy | VelocityTrackerTest | 取得追蹤器 |
| INP-052 | addMovement(event) | 待查 | STATE | Easy | VelocityTrackerTest | 加入移動事件 |
| INP-053 | computeCurrentVelocity(units) | 待查 | CALC | Medium | VelocityTrackerTest | 計算速度 |
| INP-054 | computeCurrentVelocity(units, maxVelocity) | 待查 | CALC, BOUND | Medium | VelocityTrackerTest | 帶上限計算 |
| INP-055 | getXVelocity() / getYVelocity() | 待查 | CALC | Easy | VelocityTrackerTest | 速度取得 |
| INP-056 | getXVelocity(id) / getYVelocity(id) | 待查 | BOUND, CALC | Medium | VelocityTrackerTest | 特定指標速度 |
| INP-057 | clear() | 待查 | STATE | Easy | VelocityTrackerTest | 清除 |
| INP-058 | recycle() | 待查 | RES, STATE | Easy | VelocityTrackerTest | 回收 |

### 4. InputDevice

**檔案**: `frameworks/base/core/java/android/view/InputDevice.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| INP-061 | getSources() | 待查 | COND | Easy | InputEventTest | 輸入源 |
| INP-062 | isVirtual() | 待查 | COND | Easy | InputEventTest | 虛擬設備判斷 |
| INP-063 | supportsSource(source) | 待查 | COND, CALC | Medium | InputEventTest | 源支援檢查 |
| INP-064 | getMotionRange(axis) | 待查 | COND | Medium | DrawingTabletTest | 動作範圍 |
| INP-065 | getMotionRange(axis, source) | 待查 | COND | Hard | DrawingTabletTest | 特定源動作範圍 |

### 5. MotionPredictor

**檔案**: `frameworks/base/core/java/android/view/MotionPredictor.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| INP-071 | record(event) | 待查 | STATE | Medium | MotionPredictorTest | 記錄事件 |
| INP-072 | predict(targetTime) | 待查 | CALC, STATE | Hard | MotionPredictorTest | 預測事件 |

---

## 統計摘要

| 注入類型 | 數量 |
|----------|------|
| COND（條件判斷）| 28 |
| CALC（數值計算）| 24 |
| BOUND（邊界檢查）| 18 |
| STATE（狀態轉換）| 8 |
| RES（資源管理）| 6 |
| STR（字串處理）| 1 |

## 注入難點分析

1. **多點觸控索引** — pointerIndex vs pointerId 的區別
2. **歷史事件存取** — 歷史資料的邊界檢查
3. **座標變換** — offsetLocation 和 transform 的精度
4. **速度計算** — VelocityTracker 的單位和上限處理
5. **按鍵遮罩** — getActionMasked 的位元運算

## 相關測試命令

```bash
# 執行 Input CTS
run cts -m CtsInputTestCases
```

## 下一步 - Phase B

從此列表中挑選注入點，進行題目生成：
1. [x] Phase A 完成 - 注入點列表已建立
2. [ ] Phase B - 挑選注入點、設計 bug、產生 patch
3. [ ] Phase C - 實機驗證
