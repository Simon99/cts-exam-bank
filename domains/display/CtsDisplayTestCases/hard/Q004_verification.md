# Q004 Bug Verification

## Bug 設計

**原始代碼 (正確):**
```java
} else if (wasDirty || !mTempDisplayInfo.equals(newDisplayInfo)) {
```

**Bug 版本 (錯誤):**
```java
} else if (wasDirty && !mTempDisplayInfo.equals(newDisplayInfo)) {
```

## 為什麼這個 Bug 必定會導致測試失敗

### 邏輯分析

1. **wasDirty 的狀態**
   - `mDirty` 在 LogicalDisplay 構造時設為 `true`
   - 第一次 `updateLocked()` 結束時設為 `false`
   - VirtualDisplay.resize() 不會重新設置 `mDirty = true`
   - 因此在 resize 時，`wasDirty = false`

2. **DisplayInfo 比較**
   - `mTempDisplayInfo` 在 `updateLocked()` 之前保存舊狀態
   - `newDisplayInfo` 在 `updateLocked()` 之後獲取新狀態
   - resize 改變了 density，所以 `!mTempDisplayInfo.equals(newDisplayInfo) = true`

3. **條件評估**
   - **原始 (||)**: `false || true = true` → 發送 DISPLAY_CHANGED 事件 ✓
   - **Bug (&&)**: `false && true = false` → 不發送事件 ✗

### 測試失敗機制

DisplayEventTest.testDisplayEvents 的流程：
1. 創建 VirtualDisplay（等待 DISPLAY_ADDED）
2. resize VirtualDisplay（等待 DISPLAY_CHANGED）
3. release VirtualDisplay（等待 DISPLAY_REMOVED）

當 Bug 存在時：
- resize 後不會發送 DISPLAY_CHANGED 事件
- `waitDisplayEvent(DISPLAY_CHANGED)` 會在 10 秒後超時
- `assertNotNull(event)` 失敗，測試報錯

## 與舊版本 Bug 的比較

### 舊版本（順序調換）問題：
```java
// 舊版本嘗試調換 updateLocked 和 copyFrom 的順序
display.updateLocked(mDisplayDeviceRepo);
boolean wasDirty = display.isDirtyLocked();
mTempDisplayInfo.copyFrom(display.getDisplayInfoLocked());
```

這個設計有問題：
1. 邏輯複雜，不容易理解
2. 可能有 race condition 或其他邊界情況
3. 測試有時通過有時失敗

### 新版本（邏輯運算符錯誤）優點：
1. 簡單直接，一眼就能看出問題
2. 100% 可重現的測試失敗
3. 符合真實世界中常見的拼寫錯誤（|| 寫成 &&）
4. 教學價值高：考察候選人對布林邏輯的理解

## 驗證步驟

1. 應用 Q004_bug.patch
2. 編譯 services.core
3. 刷入設備
4. 運行測試：
   ```bash
   atest CtsDisplayTestCases:DisplayEventTest#testDisplayEvents
   ```
5. 預期結果：測試失敗，超時等待 DISPLAY_CHANGED

## 版本歷史

- v1.0 (2025-02-09): 初始版本，使用順序調換 bug
- v2.0 (2025-06-24): 改用邏輯運算符錯誤，更可靠
