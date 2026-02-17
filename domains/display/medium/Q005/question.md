# CTS 診斷練習題 DIS-M005

## 題目：Private Virtual Display 創建失敗

### 背景

某團隊在開發 Android 14 的 Display 管理服務時，有一位開發者為了加強安全性，在 `VirtualDisplayAdapter` 中添加了額外的授權檢查。然而修改後，CTS 測試開始失敗。

### 失敗的 CTS 測試

```
android.hardware.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay
```

### 測試失敗訊息

```
junit.framework.AssertionFailedError: Failed to create private virtual display
    at android.hardware.display.cts.VirtualDisplayTest.testPrivateVirtualDisplay(VirtualDisplayTest.java:245)
```

### 相關源碼

請檢查以下文件：
- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

重點關注 `createVirtualDisplayLocked()` 方法中的條件判斷邏輯。

### 問題

1. 找出導致 `testPrivateVirtualDisplay` 失敗的程式碼問題
2. 解釋為什麼這個修改破壞了 private virtual display 的創建
3. 說明 public display 和 private display 在 projection 需求上的區別
4. 提供修復方案

### 提示

- Private virtual display 是只對創建它的應用可見的虛擬顯示器
- Public virtual display 可以被其他應用看到，需要更嚴格的權限控制
- 思考什麼情況下需要 MediaProjection 授權

### 時間限制

建議 25 分鐘內完成
