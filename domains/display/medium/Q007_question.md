# CTS 除錯練習題 DIS-M007

## 題目：Trusted Virtual Display 權限驗證失敗

### 背景

CTS 測試 `VirtualDisplayTest#testTrustedVirtualDisplay` 失敗。此測試驗證：

1. **具有 ADD_TRUSTED_DISPLAY 權限的應用** 可以成功創建 trusted virtual display
2. **沒有該權限的應用** 在嘗試創建時應收到 SecurityException

測試結果顯示權限檢查邏輯出現異常：有權限的應用被拒絕，而沒權限的應用可能通過。

### CTS 錯誤訊息

```
android.hardware.display.cts.VirtualDisplayTest#testTrustedVirtualDisplay FAILED

java.lang.SecurityException: Requires ADD_TRUSTED_DISPLAY permission to create a trusted virtual display.
    at android.hardware.display.DisplayManager.createVirtualDisplay(DisplayManager.java:892)
    at android.hardware.display.cts.VirtualDisplayTest.testTrustedVirtualDisplay(VirtualDisplayTest.java:456)

Expected: Virtual display creation should succeed for caller with ADD_TRUSTED_DISPLAY permission
Actual: SecurityException thrown despite having the required permission
```

### 相關知識

1. **VIRTUAL_DISPLAY_FLAG_TRUSTED**: 標記 virtual display 為系統可信任，允許顯示系統裝飾和敏感內容
2. **ADD_TRUSTED_DISPLAY 權限**: signature|privileged 級別權限，控制誰可以創建 trusted display
3. **安全考量**: Trusted display 可以顯示系統資訊，必須嚴格控制創建權限

### 任務

1. 找到 `DisplayManagerService.java` 中 VIRTUAL_DISPLAY_FLAG_TRUSTED 相關的權限驗證邏輯
2. 分析條件判斷的正確性
3. 識別並修復 bug
4. 解釋為什麼這個 bug 會導致「權限反轉」問題

### 預期完成時間

25 分鐘
