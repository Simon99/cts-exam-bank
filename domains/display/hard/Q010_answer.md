# 答案：User Disabled HDR Types 設定未被儲存

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**方法**: `setUserDisabledHdrTypesInternal()`

## Bug 描述

在 `setUserDisabledHdrTypesInternal()` 方法中，有一個錯誤的提前返回條件：當 `userDisabledHdrTypes` 數組非空時，方法直接返回，跳過了後續的存儲邏輯。

### 錯誤程式碼

```java
private void setUserDisabledHdrTypesInternal(int[] userDisabledHdrTypes) {
    synchronized (mSyncRoot) {
        // ... 驗證邏輯 ...
        
        if (!isSubsetOf(Display.HdrCapabilities.HDR_TYPES, userDisabledHdrTypes)) {
            Slog.e(TAG, "userDisabledHdrTypes contains unexpected types");
            return;
        }

        // Bug: 提前返回，跳過存儲邏輯
        if (userDisabledHdrTypes.length > 0) {
            return;  // <-- 這行是錯誤的
        }

        // 以下代碼永遠不會執行（對於非空數組）
        Arrays.sort(userDisabledHdrTypes);
        // ... 存儲到 Settings.Global ...
    }
}
```

### 正確程式碼

移除錯誤的提前返回條件：

```java
if (!isSubsetOf(Display.HdrCapabilities.HDR_TYPES, userDisabledHdrTypes)) {
    Slog.e(TAG, "userDisabledHdrTypes contains unexpected types");
    return;
}

// 直接繼續執行，不要提前返回
Arrays.sort(userDisabledHdrTypes);
// ... 存儲到 Settings.Global ...
```

## 根本原因分析

### 1. 邏輯錯誤

Bug 的作者可能誤以為這是一個「優化」— 如果數組非空就不需要存儲。但實際上：
- 非空數組正是需要被存儲的情況
- 空數組反而是「清除設定」的情況

### 2. 影響範圍

- 使用者禁用 HDR 類型的設定無法被持久化
- 設備重啟後，禁用設定會丟失
- 可能導致使用者體驗不一致（設定總是「重置」）

## CTS 測試失敗分析

測試流程：
1. 調用 `setUserDisabledHdrTypes([DOLBY_VISION, HLG])`
2. 讀取 `Settings.Global.USER_DISABLED_HDR_FORMATS`
3. 驗證值為 "1,3"（DOLBY_VISION=1, HLG=3）

由於 bug，步驟 1 沒有實際存儲值，步驟 2 讀到空字符串或舊值，導致步驟 3 驗證失敗。

## 修復方案

刪除錯誤的提前返回條件，讓方法正常執行存儲邏輯。

## 教訓

1. **提前返回的危險**：每個 return 語句都應該仔細檢查是否會跳過必要的邏輯
2. **單元測試覆蓋**：這種 bug 應該被基本的單元測試捕獲
3. **代碼審查**：提前返回條件需要特別注意審查
