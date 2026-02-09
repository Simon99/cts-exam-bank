# Q009 和 Q010 修復報告

**日期:** 2026-02-09
**分析者:** Subagent
**問題類型:** 測試繞過問題

---

## 問題摘要

| 題號 | 原 Bug | 問題 | 解決方案 |
|------|--------|------|----------|
| Q009 | equals() 遺漏 rotation 比較 | forceUpdate=true 繞過 equals() | 改為移除 defaultModeId 比較 |
| Q010 | 交換 uniqueId/ownerPackageName 順序 | 測試不驗證這些欄位 | 改為交換 defaultModeId/userPreferredModeId |

---

## Q009 深度分析

### 原始問題
- **原 Bug:** 移除 `DisplayInfo.equals()` 中的 `rotation == other.rotation` 比較
- **原目標測試:** `VirtualDisplayTest#testVirtualDisplayRotatesWithContent`

### 為什麼測試沒有失敗？

追蹤代碼路徑：

```
Activity.setRequestedOrientation()
    → WindowManager 設置 rotation
    → DisplayManagerInternal.setDisplayInfoOverrideFromWindowManager()
    → DisplayManagerGlobal.handleDisplayChangeFromWindowManager()
    → handleDisplayEvent(displayId, EVENT_DISPLAY_CHANGED, true /* forceUpdate */)
    → DisplayListenerDelegate.sendDisplayEvent()
    → handleDisplayEventInner() 中：
        if (info != null && (forceUpdate || !info.equals(mDisplayInfo))) {
            mListener.onDisplayChanged(displayId);  // forceUpdate=true 繞過 equals()
        }
```

**關鍵發現：** WindowManager 路徑總是使用 `forceUpdate=true`，完全繞過了 `equals()` 檢查！

### 尋找正確的 Bug 目標

需要找到：
1. 透過 DisplayManagerService 直接發送 DISPLAY_CHANGED 事件的場景
2. 這條路徑使用 `DisplayManagerCallback.onDisplayEvent()`，其中 `forceUpdate=false`
3. 因此會依賴 `equals()` 比較來決定是否觸發 `onDisplayChanged`

分析 `setUserPreferredDisplayMode()` 路徑：

```
DisplayManager.setGlobalUserPreferredDisplayMode()
    → DisplayManagerService.setGlobalUserPreferredDisplayMode()
    → 修改 defaultModeId
    → sendDisplayEventIfEnabledLocked(display, EVENT_DISPLAY_CHANGED)
    → DisplayManagerCallback.onDisplayEvent() [forceUpdate=false]
    → handleDisplayEventInner() 使用 equals() 比較
```

✅ 這條路徑依賴 `equals()` 比較！

### Q009 解決方案

**新 Bug 設計：** 移除 `equals()` 中的 `defaultModeId == other.defaultModeId` 比較

**新目標測試：** `DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents`

**測試邏輯：**
1. 調用 `setGlobalUserPreferredDisplayMode(newDefaultMode)`
2. 等待 `onDisplayChanged` 回調
3. 驗證 `getDefaultMode().getModeId() == newDefaultMode.getModeId()`

**預期失敗：**
- `equals()` 沒有比較 `defaultModeId` → 認為 DisplayInfo 沒有變化
- `onDisplayChanged` 不被調用
- `setUserPrefModeSignal.await()` 超時
- 測試失敗

### Q009 新 Patch

```diff
diff --git a/core/java/android/view/DisplayInfo.java b/core/java/android/view/DisplayInfo.java
--- a/core/java/android/view/DisplayInfo.java
+++ b/core/java/android/view/DisplayInfo.java
@@ -427,7 +427,6 @@ public final class DisplayInfo implements Parcelable {
                 && rotation == other.rotation
                 && modeId == other.modeId
                 && renderFrameRate == other.renderFrameRate
-                && defaultModeId == other.defaultModeId
                 && userPreferredModeId == other.userPreferredModeId
                 && Arrays.equals(supportedModes, other.supportedModes)
```

---

## Q010 深度分析

### 原始問題
- **原 Bug:** 交換 `writeToParcel()` 中 `uniqueId` 和 `ownerPackageName` 的順序
- **原目標測試:** `VirtualDisplayTest#testPrivateVirtualDisplay`

### 為什麼測試沒有失敗？

檢查 `VirtualDisplayTest.java` 中的測試邏輯：
- 只驗證 VirtualDisplay 創建成功
- 驗證 flags 正確
- 驗證 Surface 匹配
- **從未驗證 `uniqueId` 或 `ownerPackageName` 的實際值**

由於兩者都是 `String` 類型，交換後不會導致類型錯誤或 crash。

### 尋找正確的 Bug 目標

需要找到：
1. 會被 CTS 測試驗證的欄位
2. 可以安全交換（相同類型、相鄰位置）

分析 writeToParcel/readFromParcel 順序：
```
// readFromParcel 順序：
...
defaultModeId = source.readInt();      // 相鄰
userPreferredModeId = source.readInt(); // int 類型
...
```

`defaultModeId` 和 `userPreferredModeId` 都是相鄰的 `int` 欄位！

**影響分析：**
- 交換後，`getDefaultMode()` 會基於錯誤的 `defaultModeId` 返回 mode
- `getUserPreferredDisplayMode()` 會基於錯誤的 `userPreferredModeId` 返回 mode
- 多個 DefaultDisplayModeTest 測試會驗證這些值

### Q010 解決方案

**新 Bug 設計：** 交換 `writeToParcel()` 中 `defaultModeId` 和 `userPreferredModeId` 的順序

**新目標測試：** 
- `DefaultDisplayModeTest#testSetUserPreferredDisplayModeForSpecificDisplay`
- `DefaultDisplayModeTest#testGetUserPreferredDisplayMode`

**測試邏輯：**
1. 調用 `setUserPreferredDisplayMode(newMode)`
2. 驗證 `getUserPreferredDisplayMode()` 返回正確的 mode

**預期失敗：**
- Parcel 傳輸後 `defaultModeId` 和 `userPreferredModeId` 互換
- `getUserPreferredDisplayMode()` 返回錯誤的 mode
- 測試 assertion 失敗

### Q010 新 Patch

```diff
diff --git a/core/java/android/view/DisplayInfo.java b/core/java/android/view/DisplayInfo.java
--- a/core/java/android/view/DisplayInfo.java
+++ b/core/java/android/view/DisplayInfo.java
@@ -605,8 +605,8 @@ public final class DisplayInfo implements Parcelable {
         dest.writeInt(rotation);
         dest.writeInt(modeId);
         dest.writeFloat(renderFrameRate);
-        dest.writeInt(defaultModeId);
-        dest.writeInt(userPreferredModeId);
+        dest.writeInt(userPreferredModeId);    // BUG: should be defaultModeId
+        dest.writeInt(defaultModeId);          // BUG: should be userPreferredModeId
         dest.writeInt(supportedModes.length);
```

---

## 驗證步驟

### Q009 驗證
```bash
# 1. 套用新 patch
cd ~/develop_claw/aosp-sandbox-2/frameworks/base
git checkout core/java/android/view/DisplayInfo.java
patch -p1 < ~/develop_claw/cts-exam-bank/domains/display/CtsDisplayTestCases/hard/Q009_bug.patch

# 2. 編譯
cd ~/develop_claw/aosp-sandbox-2
source build/envsetup.sh && lunch aosp_panther-userdebug
m framework-minus-apex -j$(nproc)

# 3. Push 並重啟
adb root
adb remount
adb push out/target/product/panther/system/framework/*.jar /system/framework/
adb reboot

# 4. 執行測試
atest DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents

# 預期：測試 FAILED（超時等待 onDisplayChanged）
```

### Q010 驗證
```bash
# 類似步驟，使用 Q010_bug.patch
# 預期：測試 FAILED（mode 驗證失敗）
```

---

## 總結

| 題號 | 修改項目 | 新目標測試 | 預期結果 |
|------|----------|------------|----------|
| Q009 | equals() 移除 defaultModeId 比較 | DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents | 超時失敗 |
| Q010 | Parcel 交換 defaultModeId/userPreferredModeId | DefaultDisplayModeTest#testSetUserPreferredDisplayModeForSpecificDisplay | assertion 失敗 |

**優點：**
1. 兩個 bug 都會被現有 CTS 測試檢測到
2. Bug 設計合理，符合真實開發場景
3. 都涉及跨進程 IPC 傳輸問題
4. 難度適合 hard 級別（需要理解 DisplayManagerGlobal、Parcel 序列化、forceUpdate 機制）
