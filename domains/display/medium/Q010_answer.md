# Q010 答案：HDR 類型禁用設定無法清除

## Bug 分析

### 問題根源

bug 位於 `setUserDisabledHdrTypesInternal` 方法中 Settings 更新的條件邏輯：

```java
if (userDisabledHdrTypes.length != 0) {
    String userDisabledFormatsString = TextUtils.join(",",
            Arrays.stream(userDisabledHdrTypes).boxed().toArray());
    Settings.Global.putString(mContext.getContentResolver(),
            Settings.Global.USER_DISABLED_HDR_FORMATS, userDisabledFormatsString);
}
```

**問題**：`Settings.Global.putString()` 只在 `userDisabledHdrTypes.length != 0` 時執行，這表示當使用者傳入空陣列（清除所有禁用類型）時，Settings 不會被更新為空字串。

### Bug 類型

- **STATE**：系統持久化狀態（Settings）未正確更新
- **BOUND**：空陣列這個邊界條件處理不正確

### 影響

1. 使用者無法通過 UI 清除已禁用的 HDR 類型
2. 重啟後，之前禁用的 HDR 類型仍然生效
3. `mUserDisabledHdrTypes` 記憶體狀態更新了，但持久化狀態（Settings）沒有同步

## 修復方案

```java
private void setUserDisabledHdrTypesInternal(int[] userDisabledHdrTypes) {
    synchronized (mSyncRoot) {
        if (userDisabledHdrTypes == null) {
            Slog.e(TAG, "Null is not an expected argument to "
                    + "setUserDisabledHdrTypesInternal");
            return;
        }

        // Verify if userDisabledHdrTypes contains expected HDR types
        if (!isSubsetOf(Display.HdrCapabilities.HDR_TYPES, userDisabledHdrTypes)) {
            Slog.e(TAG, "userDisabledHdrTypes contains unexpected types");
            return;
        }

        Arrays.sort(userDisabledHdrTypes);
        if (Arrays.equals(mUserDisabledHdrTypes, userDisabledHdrTypes)) {
            return;
        }
        
        // 修復：無論陣列是否為空，都要更新 Settings
        String userDisabledFormatsString = "";
        if (userDisabledHdrTypes.length != 0) {
            userDisabledFormatsString = TextUtils.join(",",
                    Arrays.stream(userDisabledHdrTypes).boxed().toArray());
        }
        Settings.Global.putString(mContext.getContentResolver(),
                Settings.Global.USER_DISABLED_HDR_FORMATS, userDisabledFormatsString);
        
        mUserDisabledHdrTypes = userDisabledHdrTypes;
        if (!mAreUserDisabledHdrTypesAllowed) {
            mLogicalDisplayMapper.forEachLocked(
                    display -> {
                        display.setUserDisabledHdrTypes(userDisabledHdrTypes);
                        handleLogicalDisplayChangedLocked(display);
                    });
        }
    }
}
```

### 修復重點

1. 將 `userDisabledFormatsString` 的宣告和初始化移到 if 之外
2. 將 `Settings.Global.putString()` 移到 if 之外
3. 這樣無論 `userDisabledHdrTypes` 是空陣列還是非空陣列，Settings 都會被正確更新

## Patch

```diff
-            if (userDisabledHdrTypes.length != 0) {
-                String userDisabledFormatsString = TextUtils.join(",",
+            String userDisabledFormatsString = "";
+            if (userDisabledHdrTypes.length != 0) {
+                userDisabledFormatsString = TextUtils.join(",",
                         Arrays.stream(userDisabledHdrTypes).boxed().toArray());
-                Settings.Global.putString(mContext.getContentResolver(),
-                        Settings.Global.USER_DISABLED_HDR_FORMATS, userDisabledFormatsString);
             }
+            Settings.Global.putString(mContext.getContentResolver(),
+                    Settings.Global.USER_DISABLED_HDR_FORMATS, userDisabledFormatsString);
```

## 經驗教訓

1. **持久化狀態必須完整覆蓋所有情況**：包括「清空」這個看似簡單的操作
2. **空陣列是有效輸入**：不應該被忽略或跳過處理
3. **記憶體狀態和持久化狀態必須同步**：這裡 `mUserDisabledHdrTypes` 更新了，但 Settings 沒有同步更新
4. **測試邊界條件**：空集合、null、最大/最小值都是重要的測試案例
