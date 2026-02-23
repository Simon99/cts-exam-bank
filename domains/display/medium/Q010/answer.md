# Q010 答案：HDR 類型禁用設定未正確儲存

## Bug 分析

### 問題根源

bug 位於 `setUserDisabledHdrTypesInternal` 方法中 `TextUtils.join()` 的呼叫：

```java
String userDisabledFormatsString = "";
if (userDisabledHdrTypes.length != 0) {
    TextUtils.join(",",                                    // ← Bug：忘記賦值！
            Arrays.stream(userDisabledHdrTypes).boxed().toArray());
}
Settings.Global.putString(mContext.getContentResolver(),
        Settings.Global.USER_DISABLED_HDR_FORMATS, userDisabledFormatsString);
```

**問題**：`TextUtils.join()` 的回傳值沒有被賦值給 `userDisabledFormatsString`。這是一個典型的「遺漏賦值」錯誤。

### 完整呼叫鏈

```
1. CTS Test: testSetUserDisabledHdrTypesStoresDisabledFormatsInSettings
   └─ mDisplayManager.setUserDisabledHdrTypes([DOLBY_VISION, HLG])

2. SDK API: DisplayManager.setUserDisabledHdrTypes(int[])
   檔案: frameworks/base/core/java/android/hardware/display/DisplayManager.java:965
   └─ mGlobal.setUserDisabledHdrTypes(userDisabledTypes)

3. Client Proxy: DisplayManagerGlobal.setUserDisabledHdrTypes(int[])
   檔案: frameworks/base/core/java/android/hardware/display/DisplayManagerGlobal.java
   └─ mDm.setUserDisabledHdrTypes(userDisabledTypes)

4. Binder IPC: IDisplayManager.Stub.Proxy
   跨進程呼叫到 system_server

5. SystemServer: DisplayManagerService.BinderService.setUserDisabledHdrTypes(int[])
   └─ setUserDisabledHdrTypesInternal(userDisabledHdrTypes)

6. Bug 位置: DisplayManagerService.setUserDisabledHdrTypesInternal(int[])
   檔案: frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java:1331
   └─ TextUtils.join(",", ...) 回傳值被忽略
   └─ userDisabledFormatsString 保持為 ""
   └─ Settings.Global.putString() 寫入空字串
```

### Bug 類型

- **TYPO**：程式碼撰寫時的疏忽，忘記將函數回傳值賦值給變數
- **LOGIC**：程式邏輯錯誤，導致永遠儲存空字串

### 影響

1. 無論使用者設定什麼 HDR 禁用類型，Settings 永遠是空字串
2. `mUserDisabledHdrTypes` 記憶體狀態正確更新了，但 Settings 沒有正確同步
3. 重啟後設定會遺失（因為 Settings 是空的）
4. CTS 測試讀取 Settings 後解析會得到空陣列，驗證失敗

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
        
        String userDisabledFormatsString = "";
        if (userDisabledHdrTypes.length != 0) {
            userDisabledFormatsString = TextUtils.join(",",    // ← 修復：加上賦值
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

在 `TextUtils.join()` 呼叫前加上 `userDisabledFormatsString = `，確保回傳值被正確保存。

## Patch（反向：正確 → Bug）

```diff
             userDisabledFormatsString = TextUtils.join(",",
-                    Arrays.stream(userDisabledHdrTypes).boxed().toArray());
+            TextUtils.join(",",
+                    Arrays.stream(userDisabledHdrTypes).boxed().toArray());
```

## 經驗教訓

1. **函數回傳值必須被使用**：Java 允許忽略回傳值，但這通常是 bug
2. **IDE 警告要注意**：現代 IDE 會對「未使用的回傳值」發出警告
3. **記憶體狀態 vs 持久化狀態**：兩者必須保持同步
4. **Code Review 重點**：String builder / formatter 類的操作，檢查結果是否被正確使用
