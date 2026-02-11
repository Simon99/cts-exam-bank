# Q006: VirtualDisplay 動態 Surface 更新失效

## 問題描述

使用者回報：建立私有虛擬顯示器後，呼叫 `setVirtualDisplaySurface()` 動態更換 Surface 時，新的 Surface 沒有顯示任何內容，仍然顯示舊的畫面或黑屏。

## 重現步驟

1. 使用 `DisplayManager.createVirtualDisplay()` 建立一個私有虛擬顯示器（不帶 PUBLIC flag）
2. 將初始 Surface 綁定到該虛擬顯示器
3. 確認內容正常渲染到初始 Surface
4. 使用 `VirtualDisplay.setSurface()` 更換新的 Surface
5. **預期**：新 Surface 應該接收虛擬顯示器的內容
6. **實際**：新 Surface 沒有任何畫面更新

## 相關 Log

```
V VirtualDisplayAdapter: Update surface for VirtualDisplay TestVD
```

Log 顯示 Surface 更新有被呼叫，但實際渲染未切換到新 Surface。

## 需要分析的程式碼

**檔案**：`frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

請找出 `setSurfaceLocked()` 方法中的狀態管理問題。

## 提示

- VirtualDisplay 使用 pending changes 機制來追蹤待處理的變更
- `performTraversalLocked()` 會檢查 pending flags 來決定要執行哪些操作
- Surface 變更需要透過 SurfaceFlinger transaction 來套用

## 任務

1. 找出導致 Surface 更新失效的 bug
2. 解釋為什麼這個 bug 會導致問題
3. 提供修正方案
