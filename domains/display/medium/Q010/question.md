# Q010: HDR 類型禁用設定未正確儲存

## 背景

Android 系統允許使用者禁用特定的 HDR 類型（如 HDR10、Dolby Vision 等）。`DisplayManagerService` 負責管理這些設定，並將使用者的選擇儲存到 `Settings.Global.USER_DISABLED_HDR_FORMATS`。

一位 QA 工程師回報：「我在測試 HDR 禁用功能時，明明呼叫 API 設定了要禁用 Dolby Vision 和 HLG，但讀取 Settings 時卻是空的。」

## 問題描述

開發團隊發現以下 CTS 測試失敗：

```
android.display.cts.DisplayTest#testSetUserDisabledHdrTypesStoresDisabledFormatsInSettings
```

測試流程：
1. 設定環境，覆蓋顯示器的 HDR 支援類型
2. 呼叫 `setUserDisabledHdrTypes([DOLBY_VISION, HLG])` 禁用特定 HDR 類型
3. 從 `Settings.Global.USER_DISABLED_HDR_FORMATS` 讀取儲存的值
4. 驗證值正確（應包含 DOLBY_VISION=1 和 HLG=3）

測試在步驟 4 失敗：Settings 中的值是空的，沒有正確儲存禁用的 HDR 類型。

## 呼叫鏈

```
CTS Test
  └─ DisplayManager.setUserDisabledHdrTypes(int[])
      └─ DisplayManagerGlobal.setUserDisabledHdrTypes(int[])
          └─ IDisplayManager.Stub (Binder IPC)
              └─ DisplayManagerService.setUserDisabledHdrTypesInternal(int[])
                  └─ TextUtils.join() → Settings.Global.putString()
```

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
        String userDisabledFormatsString = "";
        if (userDisabledHdrTypes.length != 0) {
            TextUtils.join(",",
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

## 任務

1. 找出導致測試失敗的 bug
2. 解釋為什麼這個 bug 會導致「Settings 儲存值為空」
3. 提供修復方案

## 提示

- 仔細觀察 `TextUtils.join()` 的呼叫方式
- 思考函數回傳值的用途
- Java 中沒有使用的回傳值會發生什麼事？
