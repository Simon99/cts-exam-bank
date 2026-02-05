# Display-E-Q004 解答

## Root Cause
`DisplayManagerService.java` 第 4105 行，`setBrightnessConfigurationForUser()` 方法中的權限檢查被註解掉。

原本：
```java
setBrightnessConfigurationForUser_enforcePermission();
```

被改成：
```java
// setBrightnessConfigurationForUser_enforcePermission();
```

CTS 測試 `testConfigureBrightnessPermission` 的邏輯是：以**無權限**的身份呼叫 `setBrightnessConfigurationForUser()`，預期應該拋出 `SecurityException`。由於權限檢查被移除，呼叫成功沒有拋出例外 → `fail()` 被執行。

## 涉及檔案
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`（第 4105 行）

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → `BrightnessTest.java:325` 的 `fail()` 被執行
2. 查 CTS 源碼 → 測試在 try-catch 中呼叫 setBrightnessConfiguration，預期 SecurityException
3. `fail()` 在 try block 裡 → 代表沒有拋出例外
4. 追蹤 `setBrightnessConfigurationForUser` Binder 呼叫到 DMS
5. 發現 `enforcePermission()` 被註解掉 → 無權限呼叫也成功

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 DisplayManagerService.java |
| 正確定位 bug 位置 | 20% | 權限檢查被註解 |
| 理解 root cause | 20% | 理解 CTS 是反向測試（驗證權限保護存在） |
| 修復方案正確 | 10% | 取消註解恢復權限檢查 |
| 無 side effect | 10% | 不影響有權限的正常呼叫 |

## 常見錯誤方向
- 不理解「反向測試」的邏輯（CTS 預期失敗而不是成功）
- 去找 Brightness 的值邏輯而不是權限邏輯
