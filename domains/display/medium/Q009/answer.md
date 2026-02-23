# Q009: 答案與解析

## 正確答案

**B. VirtualDisplayAdapter 中的重複檢查條件被反轉**

---

## CTS 測試路徑

**測試方法**：`android.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay`

**呼叫鏈**：
1. `VirtualDisplayTest.testPrivateVirtualDisplay()`
   - 呼叫 `mDisplayManager.createVirtualDisplay(NAME, WIDTH, HEIGHT, DENSITY, mSurface, 0)`
2. → `DisplayManager.createVirtualDisplay(String, int, int, int, Surface, int)`
   - 轉發到多參數版本
3. → `DisplayManager.createVirtualDisplay(String, int, int, int, Surface, int, Callback, Handler)`
   - 建構 `VirtualDisplayConfig.Builder` 並呼叫下一層
4. → `DisplayManager.createVirtualDisplay(MediaProjection, VirtualDisplayConfig, Callback, Handler)`
   - 呼叫 `mGlobal.createVirtualDisplay()`
5. → `DisplayManagerGlobal.createVirtualDisplay(Context, MediaProjection, VirtualDisplayConfig, Callback, Executor)`
   - 呼叫 `mDm.createVirtualDisplay()` (Binder 呼叫到 IDisplayManager)
6. → `DisplayManagerService.BinderService.createVirtualDisplay()`
   - 呼叫 `createVirtualDisplayInternal()`
7. → `DisplayManagerService.createVirtualDisplayInternal()`
   - 進行權限檢查和 flag 驗證，然後呼叫 `createVirtualDisplayLocked()`
8. → `DisplayManagerService.createVirtualDisplayLocked()`
   - 呼叫 `mVirtualDisplayAdapter.createVirtualDisplayLocked()`
9. → **`VirtualDisplayAdapter.createVirtualDisplayLocked()`** ← Bug 注入點

---

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

**函數**：`createVirtualDisplayLocked()`

**行號**：120

---

## Bug 分析

### 錯誤程式碼

```java
public DisplayDevice createVirtualDisplayLocked(IVirtualDisplayCallback callback,
        IMediaProjection projection, int ownerUid, String ownerPackageName, String uniqueId,
        Surface surface, int flags, VirtualDisplayConfig virtualDisplayConfig) {
    IBinder appToken = callback.asBinder();
    if (!mVirtualDisplayDevices.containsKey(appToken)) {  // ← BUG：條件被反轉
        Slog.wtfStack(TAG,
                "Can't create virtual display, display with same appToken already exists");
        return null;
    }
    // ...
}
```

### 正確程式碼

```java
public DisplayDevice createVirtualDisplayLocked(IVirtualDisplayCallback callback,
        IMediaProjection projection, int ownerUid, String ownerPackageName, String uniqueId,
        Surface surface, int flags, VirtualDisplayConfig virtualDisplayConfig) {
    IBinder appToken = callback.asBinder();
    if (mVirtualDisplayDevices.containsKey(appToken)) {  // ← 正確：已存在才返回 null
        Slog.wtfStack(TAG,
                "Can't create virtual display, display with same appToken already exists");
        return null;
    }
    // ...
}
```

### 問題本質

條件判斷運算符被意外反轉（`containsKey` → `!containsKey`）。

原始邏輯：**如果 appToken 已存在**，表示這是重複建立，應該返回 null 並記錄錯誤。

錯誤邏輯：**如果 appToken 不存在**（即正常的首次建立），就返回 null 並記錄錯誤。

### 影響

- **正常建立請求**：首次建立 VirtualDisplay 時，appToken 尚未存在於 `mVirtualDisplayDevices` map 中，但錯誤的條件會將其判定為「已存在」並拒絕建立。
- **CTS 測試**：所有需要建立 VirtualDisplay 的測試都會失敗，因為 `createVirtualDisplay()` 總是返回 null。
- **日誌誤導**：錯誤訊息宣稱「display with same appToken already exists」，但實際上是首次建立。

---

## 選項分析

### A. DisplayManager 的 Binder 連線失敗 ❌

錯誤。如果是 Binder 通訊問題，會拋出 `RemoteException` 或類似的異常，而不是返回 null 並記錄「appToken already exists」的訊息。

### B. VirtualDisplayAdapter 中的重複檢查條件被反轉 ✅

正確。日誌訊息「display with same appToken already exists」來自 `VirtualDisplayAdapter.createVirtualDisplayLocked()`。但這是首次建立，appToken 不應該已存在，說明條件檢查邏輯有誤。

### C. Surface 物件未正確初始化 ❌

錯誤。Surface 驗證發生在更早的階段（`createVirtualDisplayInternal()`），且會有不同的錯誤訊息。日誌明確指向 appToken 重複問題，與 Surface 無關。

### D. VirtualDisplayConfig 參數驗證失敗 ❌

錯誤。VirtualDisplayConfig 的參數驗證也在 `createVirtualDisplayInternal()` 中進行，且會拋出 `IllegalArgumentException`，不會產生「appToken already exists」的訊息。

---

## 修復方式

將條件從 `!mVirtualDisplayDevices.containsKey(appToken)` 改回 `mVirtualDisplayDevices.containsKey(appToken)`：

```diff
-        if (!mVirtualDisplayDevices.containsKey(appToken)) {
+        if (mVirtualDisplayDevices.containsKey(appToken)) {
```

---

## 相關知識點

1. **VirtualDisplay 生命週期**：VirtualDisplay 透過 appToken（IBinder）作為唯一識別符，用於追蹤和管理虛擬顯示器的生命週期。

2. **防止重複建立**：同一個 callback 不應該被用於建立多個 VirtualDisplay，因此需要檢查 appToken 是否已存在。

3. **條件反轉 Bug 模式**：這是開發中常見的邏輯錯誤，可能因為：
   - 複製貼上時忘記修改
   - 重構時意外引入
   - 誤解原始邏輯意圖

---

## 延伸閱讀

- `DisplayManagerService.createVirtualDisplayInternal()` - 處理權限和 flag 驗證
- `VirtualDisplayAdapter.VirtualDisplayDevice` - VirtualDisplay 的設備抽象層
- `DisplayManagerGlobal` - 客戶端與服務端的橋樑
