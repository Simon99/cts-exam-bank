# CTS 除錯題目：Virtual Display Private Flag Bug

## 題目背景

你是 Android Display 團隊的工程師。QA 回報了以下問題：

**Bug Report #DIS-2024-0912**  
**嚴重程度**: High  
**影響範圍**: 虛擬顯示器隱私功能

**問題描述**:  
用戶回報第三方應用程式在創建私有虛擬顯示器（Private Virtual Display）時，系統未正確將其標記為私有，導致安全性問題。私有虛擬顯示器應該只對創建它的應用程式可見，但現在其他應用程式似乎能夠發現並可能訪問這些顯示器。

**重現步驟**:
1. 使用 DisplayManager.createVirtualDisplay() 創建不帶 VIRTUAL_DISPLAY_FLAG_PUBLIC 的虛擬顯示器
2. 檢查返回的 Display 物件的 flags
3. 觀察 Display.FLAG_PRIVATE 是否被正確設置

**預期行為**: 創建時未設置 VIRTUAL_DISPLAY_FLAG_PUBLIC 的虛擬顯示器應該自動獲得 FLAG_PRIVATE 標記，確保僅對創建者可見。

**實際行為**: FLAG_PRIVATE 未被正確設置，虛擬顯示器可能被其他應用程式訪問。

---

## CTS 測試失敗資訊

```
FAIL: android.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay

java.lang.AssertionError: Expected flag Display.FLAG_PRIVATE to be set
Expected: display flags contain FLAG_PRIVATE (0x4)
Actual: display flags = 0x0 (no FLAG_PRIVATE)

    at android.display.cts.VirtualDisplayTest.assertDisplayRegistered(VirtualDisplayTest.java:536)
    at android.display.cts.VirtualDisplayTest.testPrivateVirtualDisplay(VirtualDisplayTest.java:198)
```

---

## 相關檔案

請檢查以下檔案，找出導致 CTS 測試失敗的根本原因：

- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

重點關注 `VirtualDisplayDevice` 內部類別的 `getDisplayDeviceInfoLocked()` 方法中，關於 display flags 的設置邏輯。

---

## 任務

1. **分析程式碼**：找出導致 FLAG_PRIVATE 未正確設置的 bug
2. **解釋問題**：說明為什麼這個 bug 會導致上述 CTS 測試失敗
3. **提供修復**：給出正確的程式碼修復方案

---

## 評分標準

- **定位準確** (40%): 正確指出有問題的程式碼位置
- **分析完整** (30%): 清楚解釋 bug 的成因與影響
- **修復正確** (30%): 提供正確且符合規範的修復方案
