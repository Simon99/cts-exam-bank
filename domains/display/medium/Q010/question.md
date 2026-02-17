# Q010: HDR 類型禁用設定無法清除

## 背景

Android 系統允許使用者禁用特定的 HDR 類型（如 HDR10、Dolby Vision 等）。`DisplayManagerService` 負責管理這些設定，並將使用者的選擇儲存到 `Settings.Global.USER_DISABLED_HDR_FORMATS`。

一位使用者回報：「我在設定中禁用了 HDR10 和 Dolby Vision，之後又把它們全部取消（清空列表），但重啟後這些 HDR 類型還是被禁用。」

## 問題描述

開發團隊發現以下 CTS 測試失敗：

```
android.display.cts.DisplayTest#testSetUserDisabledHdrTypesStoresDisabledFormatsInSettings
```

測試流程：
1. 呼叫 `setUserDisabledHdrTypes([HDR10, DOLBY_VISION])` 禁用特定 HDR 類型
2. 驗證 Settings 中儲存了正確的值
3. 呼叫 `setUserDisabledHdrTypes([])` 清除所有禁用類型
4. 驗證 Settings 中的值已被清空（應為空字串）

測試在步驟 4 失敗：Settings 仍包含之前禁用的 HDR 類型。

## 程式碼片段

以下是 `DisplayManagerService.java` 中 `setUserDisabledHdrTypesInternal` 方法的相關部分：

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
        if (userDisabledHdrTypes.length != 0) {
            String userDisabledFormatsString = TextUtils.join(",",
                    Arrays.stream(userDisabledHdrTypes).boxed().toArray());
            Settings.Global.putString(mContext.getContentResolver(),
                    Settings.Global.USER_DISABLED_HDR_FORMATS, userDisabledFormatsString);
        }
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

## 任務

1. 找出導致測試失敗的 bug
2. 解釋為什麼這個 bug 會導致「清除 HDR 禁用設定」功能失效
3. 提供修復方案

## 提示

- 仔細觀察空陣列（`[]`）和非空陣列的處理邏輯差異
- 思考 Settings 應該在什麼情況下被更新
- 考慮使用者操作的完整流程：禁用 → 清除 → 重啟
