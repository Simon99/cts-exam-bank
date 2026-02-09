# Q003, Q004, Q009 測試對應問題修復報告

**日期：** 2025-02-09
**問題：** 這三題的 bug 已成功套用，但 CTS 測試沒有抓到

---

## Q003: VirtualDisplay RequestedRefreshRate 問題

### 原始設計
- **Bug 位置：** `VirtualDisplayAdapter.getDisplayDeviceInfoLocked()` 第 466 行
- **Bug 內容：** `mInfo.renderFrameRate = REFRESH_RATE` (固定 60Hz)
- **目標測試：** `VirtualDisplayTest#testVirtualDisplayWithRequestedRefreshRate`

### 問題分析
測試使用 `display.getRefreshRate()` 獲取刷新率，這個方法的調用路徑是：
1. `Display.getRefreshRate()` → `DisplayInfo.getRefreshRate()`
2. `DisplayInfo.getRefreshRate()` → `getMode().getRefreshRate()`
3. `getMode()` 返回的 mode 是從 `supportedModes` 中查找的

**關鍵發現：** 測試使用的是 `mode.getRefreshRate()`，**不是** `renderFrameRate` 欄位！

Bug 修改的 `renderFrameRate` 欄位根本沒有被測試使用。

### 修復方案 ✓
重新設計 bug 位置，修改 `VirtualDisplayDevice.getRefreshRate()` 方法：
```java
// 原始代碼
private float getRefreshRate() {
    return (mRequestedRefreshRate != 0.0f) ? mRequestedRefreshRate : REFRESH_RATE;
}

// Bug 代碼
private float getRefreshRate() {
    return REFRESH_RATE;  // 忽略 mRequestedRefreshRate
}
```

這樣 mode 創建時會使用錯誤的刷新率，測試就能檢測到。

### 更新內容
- [x] 創建新的 `Q003_bug.patch`（修改第 571-572 行）
- [x] 更新 `Q003_meta.json` 中的 bugMethod 和 bugLine
- [x] 保留原 patch 為 `Q003_bug.patch.old`

---

## Q004: Display 事件狀態比較順序錯誤

### 原始設計
- **Bug 位置：** `LogicalDisplayMapper.updateLogicalDisplaysLocked()` 第 717 行附近
- **Bug 內容：** 調換 `updateLocked` 和 `isDirtyLocked/copyFrom` 的順序
- **目標測試：** `DisplayEventTest#testDisplayEvents`

### 問題分析
Bug 設計看起來是正確的：
1. 原始順序：先 `copyFrom` 保存舊狀態，再 `updateLocked` 更新
2. Bug 順序：先 `updateLocked` 更新，再 `copyFrom`（複製的是已更新的狀態）

這會導致 `mTempDisplayInfo.equals(newDisplayInfo)` 返回 true，不發送 `DISPLAY_CHANGED` 事件。

### 待確認事項 ⚠
- Patch 格式正確，可以成功套用
- 測試 `testDisplayEvents` 會調用 `resize()` 並等待 `DISPLAY_CHANGED` 事件
- 理論上 bug 應該導致測試超時失敗

### 可能原因
1. 驗證時編譯/刷機流程問題
2. 有其他代碼路徑仍然發送事件
3. `resize()` 導致的其他變化觸發了 dirty 標記

### 建議
- 保持現有設計不變
- 在乾淨環境中重新驗證
- 如果仍然無法檢測，需要深入分析 resize 事件路徑

---

## Q009: DisplayInfo.equals() 遺漏 rotation 比較

### 原始設計
- **Bug 位置：** `DisplayInfo.equals()` 方法
- **Bug 內容：** 移除 `rotation == other.rotation` 比較
- **原目標測試：** `DisplayTest#testDisplayListener` (不存在！)

### 問題分析
1. 指定的測試 `DisplayTest#testDisplayListener` **不存在**
2. Bug 設計是正確的：缺少 rotation 比較會導致 `DisplayManagerGlobal` 認為 DisplayInfo 沒有變化
3. 但 CtsDisplayTestCases 中有一個更好的測試可以使用

### 發現正確的測試 ✓
`VirtualDisplayTest#testVirtualDisplayRotatesWithContent` 正好可以檢測這個 bug：
1. 測試創建 VirtualDisplay 並使用 `RotationChangeWaiter` 監聽 rotation 變化
2. `RotationChangeWaiter` 使用 `DisplayListener.onDisplayChanged()` 回調
3. 當 rotation 變化但 `equals()` 缺少 rotation 比較時，`onDisplayChanged()` 不會被調用
4. `assertTrue(waiter.rotationChanged())` 會失敗

### 更新內容 ✓
- [x] 更新 `Q009_meta.json` 中的 `related_cts_tests`
- [x] 添加 `targetTests` 和 `ctsCommand` 欄位
- [x] 指向 `VirtualDisplayTest#testVirtualDisplayRotatesWithContent`

---

## 總結

| 題號 | 狀態 | 修復方案 |
|------|------|----------|
| Q003 | ✅ 已修復 | 重新設計 bug 位置到 getRefreshRate() 方法 |
| Q004 | ⚠ 待驗證 | 保持設計，建議重新驗證 |
| Q009 | ✅ 已修復 | 更新 meta.json 指向正確的測試 |

### 下一步
1. 在乾淨環境中重新驗證 Q003 和 Q009
2. 對 Q004 進行更深入的調試，確認 bug 是否被正確套用
3. 如果 Q004 仍然無法被檢測，考慮修改 bug 設計或目標測試
