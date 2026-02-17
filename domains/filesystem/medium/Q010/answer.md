# Q010 答案：OBB 包名驗證與路徑檢查錯誤

## Bug 位置

### Bug 1: StorageManagerService.java
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 2523 行
**問題:** 包名比較邏輯反轉（`!callingPackage.equals` 應為 `callingPackage.equals`）

### Bug 2: ObbInfo.java
**檔案路徑:** `frameworks/base/core/java/android/content/res/ObbInfo.java`
**行號:** 約 88 行
**問題:** `getPackageName()` 返回小寫版本，破壞大小寫敏感的比較

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
if (obbInfo != null && !callingPackage.equals(obbInfo.packageName)) {
    return true;
}

// 正確代碼
if (obbInfo != null && callingPackage.equals(obbInfo.packageName)) {
    return true;
}
```

### 修復 Bug 2:
```java
// 錯誤代碼
public String getPackageName() {
    return packageName != null ? packageName.toLowerCase() : null;
}

// 正確代碼
public String getPackageName() {
    return packageName;
}
```

## 根本原因分析

這是一個 **安全檢查邏輯 + 大小寫處理** 雙重錯誤：

1. Service 層的包名檢查邏輯反轉，允許錯誤的包名
2. ObbInfo 返回小寫包名，與原始包名不匹配

安全影響：
- 錯誤的應用可以掛載其他應用的 OBB
- 正確的應用反而無法掛載自己的 OBB

## 調試思路

1. CTS 測試用錯誤包名嘗試掛載 OBB
2. 預期失敗但實際成功
3. 追蹤 `isCallerAllowedToMountObb()` 邏輯
4. 發現條件判斷反轉
5. 修復後仍有問題，檢查 `getPackageName()` 返回值
