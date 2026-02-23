# Q009: VirtualDisplay 建立失敗

## 題目背景

CTS 測試 `VirtualDisplayTest#testPrivateVirtualDisplay` 失敗，測試報告顯示：

```
java.lang.AssertionError: virtual display must not be null
    at org.junit.Assert.fail(Assert.java:89)
    at org.junit.Assert.assertTrue(Assert.java:42)
    at org.junit.Assert.assertNotNull(Assert.java:712)
    at android.display.cts.VirtualDisplayTest.testPrivateVirtualDisplay(VirtualDisplayTest.java:168)
```

## CTS 測試程式碼

```java
// VirtualDisplayTest.java
@Test
public void testPrivateVirtualDisplay() throws Exception {
    VirtualDisplay virtualDisplay = mDisplayManager.createVirtualDisplay(NAME,
            WIDTH, HEIGHT, DENSITY, mSurface, 0);
    assertNotNull("virtual display must not be null", virtualDisplay);
    // ...
}
```

## 相關日誌

```
W/VirtualDisplayAdapter: Can't create virtual display, display with same appToken already exists
```

日誌訊息顯示 "display with same appToken already exists"，但這是第一次呼叫 `createVirtualDisplay()`。

## 問題

以下哪個是導致 VirtualDisplay 建立失敗的最可能原因？

---

## 選項

### A. DisplayManager 的 Binder 連線失敗

Framework 層的 `DisplayManagerGlobal` 與 `DisplayManagerService` 之間的 Binder 通訊發生錯誤，導致 `createVirtualDisplay()` 呼叫無法送達服務端。

### B. VirtualDisplayAdapter 中的重複檢查條件被反轉

`VirtualDisplayAdapter.createVirtualDisplayLocked()` 方法中檢查 appToken 是否已存在的條件邏輯錯誤，導致正常的首次建立被錯誤拒絕。

### C. Surface 物件未正確初始化

傳入的 `Surface` 物件狀態無效或已被釋放，導致 `DisplayManagerService` 驗證 Surface 時失敗並返回 null。

### D. VirtualDisplayConfig 參數驗證失敗

`VirtualDisplayConfig` 的建構參數（如 width、height、density）未通過驗證，導致建立過程被中斷。

---

**難度**: Medium  
**領域**: Display  
**涉及檔案**: `VirtualDisplayAdapter.java`
