# CTS 答案：DIS-H008

## 1. 定位問題 (10分)

### 問題檔案與方法
- **檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`
- **方法**: `createVirtualDisplayInternal()`
- **位置**: 約第 1557 行

### 權限檢查的目的
`ADD_TRUSTED_DISPLAY` 權限檢查保護以下功能：
- 防止未授權應用創建 trusted virtual display
- Trusted display 可以顯示系統裝飾（status bar、navigation bar）
- Trusted display 可以接收系統事件和敏感輸入
- 這是一個 signature-level 權限，只有系統應用才應該擁有

---

## 2. 根因分析 (15分)

### 錯誤的條件邏輯

**Bug 代碼**:
```java
if (callingUid == Process.SYSTEM_UID || (flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
    if (!checkCallingPermission(ADD_TRUSTED_DISPLAY, "createVirtualDisplay()")) {
        // throw SecurityException
    }
}
```

**正確代碼**:
```java
if (callingUid != Process.SYSTEM_UID && (flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0) {
    if (!checkCallingPermission(ADD_TRUSTED_DISPLAY, "createVirtualDisplay()")) {
        // throw SecurityException
    }
}
```

### De Morgan's Law 分析

這個 bug 是典型的條件反轉錯誤，涉及 De Morgan's Law：

設 A = `callingUid != Process.SYSTEM_UID`（非系統 UID）
設 B = `(flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0`（請求 trusted flag）

**正確條件**（何時應該檢查權限）：
- `A && B` → 非系統 UID **且**請求 trusted flag

**錯誤條件**：
- `!A || !B` → 系統 UID **或**沒有請求 trusted flag

根據 De Morgan's Law：`!(A && B) = !A || !B`

這意味著錯誤條件恰好是正確條件的**邏輯反轉**！

### 真值表分析

| 呼叫者 | 請求 Trusted | 正確：檢查權限？ | 錯誤：檢查權限？ |
|--------|-------------|-----------------|-----------------|
| 系統 UID | 否 | 否 ✓ | 是 ✗ |
| 系統 UID | 是 | 否 ✓ | 是 ✗ |
| 第三方 App | 否 | 否 ✓ | 是 ✗ |
| 第三方 App | 是 | **是 ✓** | **否 ✗** |

### 關鍵問題

最後一行是安全漏洞：**第三方應用請求 trusted display 時不檢查權限**！

這讓惡意應用可以：
1. 創建 trusted virtual display（本應被拒絕）
2. 獲得系統級顯示能力
3. 繞過 Android 的安全邊界

---

## 3. 安全影響評估 (5分)

### 安全風險

1. **系統裝飾偽造**
   - 惡意應用可以在 trusted display 上偽造 status bar
   - 可能顯示假的網路狀態、電量、通知圖標
   - 用於釣魚攻擊

2. **敏感資訊竊取**
   - Trusted display 可以接收 FLAG_SECURE 內容
   - 可能截取銀行應用、密碼管理器的畫面
   - 繞過 DRM 保護

3. **輸入劫持**
   - 在 trusted display 上覆蓋透明層
   - 記錄用戶輸入（密碼、PIN 碼）
   - Tap-jacking 攻擊

4. **權限提升**
   - Trusted display 可以顯示系統對話框
   - 可能誘導用戶授予更多權限
   - 繞過 permission prompt 保護

### 為什麼需要特殊權限

`ADD_TRUSTED_DISPLAY` 是 signature 權限因為：
- 只有 OEM 簽名的系統應用才能創建 trusted display
- 這確保只有可信任的組件能獲得系統級顯示能力
- 違反這個原則會破壞 Android 的沙箱模型

---

## 4. 修復方案 (5分)

### 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -1554,7 +1554,7 @@ class DisplayManagerService extends SystemService {
             }
         }
 
-        if (callingUid == Process.SYSTEM_UID || (flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
+        if (callingUid != Process.SYSTEM_UID && (flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0) {
             if (!checkCallingPermission(ADD_TRUSTED_DISPLAY, "createVirtualDisplay()")) {
                 EventLog.writeEvent(0x534e4554, "162627132", callingUid,
                         "Attempt to create a trusted display without holding permission!");
```

### 修復說明

修復確保：
1. **系統 UID 不受影響**：`callingUid != Process.SYSTEM_UID` 條件讓系統進程跳過權限檢查
2. **只在需要時檢查**：`(flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0` 只對請求 trusted flag 的呼叫者檢查
3. **正確拒絕**：沒有 `ADD_TRUSTED_DISPLAY` 權限的第三方應用會收到 `SecurityException`

### 驗證方法

```bash
# 運行 CTS 測試驗證修復
atest VirtualDisplayTest#testTrustedVirtualDisplay
```

---

## 評分標準

| 題目 | 滿分 | 得分標準 |
|-----|------|---------|
| 定位問題 | 10 | 正確指出檔案(5)、方法(3)、權限目的(2) |
| 根因分析 | 15 | De Morgan 分析(5)、真值表(5)、漏洞解釋(5) |
| 安全影響 | 5 | 3個風險(3)、權限說明(2) |
| 修復方案 | 5 | 正確 patch(3)、驗證(2) |
| **總分** | **35** | |

---

## 延伸學習

1. **Android Permission Model**
   - Normal, Dangerous, Signature permissions 的區別
   - Runtime vs Install-time permissions

2. **Virtual Display 安全模型**
   - `FLAG_SECURE` 的作用
   - MediaProjection 與 Virtual Display 的關係

3. **常見邏輯錯誤模式**
   - 條件反轉（本題）
   - 短路求值錯誤
   - 邊界條件遺漏
