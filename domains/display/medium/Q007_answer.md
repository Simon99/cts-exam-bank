# DIS-M007 解答

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`  
**位置**: `createVirtualDisplayInternal()` 方法中的 VIRTUAL_DISPLAY_FLAG_TRUSTED 權限檢查（約第 1556 行）

## 問題分析

### 原始錯誤代碼

```java
if (callingUid != Process.SYSTEM_UID && (flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0) {
    // Fixed: Added proper validation for trusted display creation
    if (checkCallingPermission(ADD_TRUSTED_DISPLAY, "createVirtualDisplay()")) {
        EventLog.writeEvent(0x534e4554, "162627132", callingUid,
                "Attempt to create a trusted display without holding permission!");
        throw new SecurityException("Requires ADD_TRUSTED_DISPLAY permission to "
                + "create a trusted virtual display.");
    }
}
```

### Bug 類型

**條件反轉（Inverted Condition）** - 權限檢查邏輯被反轉

### 問題根因

`checkCallingPermission()` 方法在呼叫者**有**權限時返回 `true`。

錯誤的邏輯：
- 當 `checkCallingPermission()` 返回 `true`（有權限）→ 拋出 SecurityException（拒絕）
- 當 `checkCallingPermission()` 返回 `false`（無權限）→ 不拋出異常（允許）

這完全顛倒了預期行為！

### 正確邏輯

應該在**沒有**權限時才拋出異常：

```java
if (callingUid != Process.SYSTEM_UID && (flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0) {
    if (!checkCallingPermission(ADD_TRUSTED_DISPLAY, "createVirtualDisplay()")) {
        EventLog.writeEvent(0x534e4554, "162627132", callingUid,
                "Attempt to create a trusted display without holding permission!");
        throw new SecurityException("Requires ADD_TRUSTED_DISPLAY permission to "
                + "create a trusted virtual display.");
    }
}
```

## 修復方式

將 `if (checkCallingPermission(...))` 改為 `if (!checkCallingPermission(...))`

## 安全影響分析

此 bug 造成嚴重的安全漏洞：

1. **權限提升攻擊**: 無權限的應用可以創建 trusted virtual display
2. **敏感資訊洩露**: trusted display 可以顯示系統裝飾，可能包含敏感通知
3. **權限繞過**: 正常的權限檢查機制完全失效

### CVE 關聯

代碼中的 `EventLog.writeEvent(0x534e4554, "162627132", ...)` 表明這與 [CVE-2021-0478](https://source.android.com/security/bulletin/2021-06-01) 相關，該漏洞允許惡意應用創建 trusted display 來讀取敏感資訊。

## 測試驗證要點

1. **正向測試**: 具有 ADD_TRUSTED_DISPLAY 權限的應用應能成功創建 trusted display
2. **負向測試**: 沒有權限的應用嘗試創建時應收到 SecurityException
3. **系統 UID 測試**: SYSTEM_UID 不需要權限檢查，應直接通過

## 修復 Patch

```diff
-            if (checkCallingPermission(ADD_TRUSTED_DISPLAY, "createVirtualDisplay()")) {
+            if (!checkCallingPermission(ADD_TRUSTED_DISPLAY, "createVirtualDisplay()")) {
```

## 經驗教訓

1. **權限檢查邏輯需要仔細審查**: 條件反轉是常見的安全漏洞
2. **誤導性註解危險**: "Fixed: Added proper validation" 這樣的註解可能隱藏 bug
3. **單元測試重要性**: 正向和負向測試都要覆蓋，才能發現這類問題
