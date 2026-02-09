# Q005 答案

## Bug 分析

這是一個涉及 **3 個檔案** 的多檔案交互 bug，影響 HDR 用戶禁用類型的傳遞機制。

### 涉及的檔案

1. **DisplayManagerService.java** - 管理 HDR 類型禁用設置
2. **LogicalDisplay.java** - 存儲和同步 DisplayInfo
3. **Display.java** - 最終 API 層的過濾邏輯

### Bug 1：DisplayManagerService 變量混淆

**位置：** `setAreUserDisabledHdrTypesAllowedInternal()`

**錯誤代碼：**
```java
int[] finalUserDisabledHdrTypes = userDisabledHdrTypes;
mLogicalDisplayMapper.forEachLocked(
        display -> {
            display.setUserDisabledHdrTypes(mUserDisabledHdrTypes);  // BUG!
            handleLogicalDisplayChangedLocked(display);
        });
```

**問題：**
Lambda 中應該使用局部變量 `finalUserDisabledHdrTypes`，但錯誤地使用了成員變量 `mUserDisabledHdrTypes`。

當 `mAreUserDisabledHdrTypesAllowed` 為 `true` 時：
- `finalUserDisabledHdrTypes` 應該是空數組 `{}`
- 但 `mUserDisabledHdrTypes` 仍然包含禁用的類型

**修復：**
```java
display.setUserDisabledHdrTypes(finalUserDisabledHdrTypes);
```

### Bug 2：LogicalDisplay 條件反轉

**位置：** `setUserDisabledHdrTypes()`

**錯誤代碼：**
```java
public void setUserDisabledHdrTypes(@NonNull int[] userDisabledHdrTypes) {
    if (Arrays.equals(mUserDisabledHdrTypes, userDisabledHdrTypes)) {  // BUG!
        mUserDisabledHdrTypes = userDisabledHdrTypes;
        mBaseDisplayInfo.userDisabledHdrTypes = userDisabledHdrTypes;
        mInfo.set(null);
    }
}
```

**問題：**
條件判斷被反轉了！只有當新舊數組**相等**時才更新，這意味著：
- 當數組內容不同（需要更新）時，不會執行更新
- 當數組內容相同（不需要更新）時，反而執行更新

**正確代碼應該是：**
```java
if (!Arrays.equals(mUserDisabledHdrTypes, userDisabledHdrTypes)) {
```

或者使用原始的引用比較：
```java
if (mUserDisabledHdrTypes != userDisabledHdrTypes) {
```

### 數據流影響

```
DisplayManagerService
    ↓ (Bug 1: 傳遞錯誤的數組)
LogicalDisplay.setUserDisabledHdrTypes()
    ↓ (Bug 2: 條件反轉，不更新 mBaseDisplayInfo)
DisplayInfo.userDisabledHdrTypes = {} (空數組)
    ↓
Display.getHdrCapabilities()
    ↓ (因為 userDisabledHdrTypes.length == 0，不執行過濾)
返回完整的 HDR 類型列表
```

### 修復 Patch

```diff
--- a/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -1370,7 +1370,7 @@ public final class DisplayManagerService extends SystemService {
             int[] finalUserDisabledHdrTypes = userDisabledHdrTypes;
             mLogicalDisplayMapper.forEachLocked(
                     display -> {
-                        display.setUserDisabledHdrTypes(mUserDisabledHdrTypes);
+                        display.setUserDisabledHdrTypes(finalUserDisabledHdrTypes);
                         handleLogicalDisplayChangedLocked(display);
                     });
         }

--- a/services/core/java/com/android/server/display/LogicalDisplay.java
+++ b/services/core/java/com/android/server/display/LogicalDisplay.java
@@ -819,7 +819,7 @@ final class LogicalDisplay {
     }
 
     public void setUserDisabledHdrTypes(@NonNull int[] userDisabledHdrTypes) {
-        if (Arrays.equals(mUserDisabledHdrTypes, userDisabledHdrTypes)) {
+        if (mUserDisabledHdrTypes != userDisabledHdrTypes) {
             mUserDisabledHdrTypes = userDisabledHdrTypes;
             mBaseDisplayInfo.userDisabledHdrTypes = userDisabledHdrTypes;
             mInfo.set(null);
```

### 測試驗證

修復後，`testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes` 測試應該通過：

1. 設置 `setAreUserDisabledHdrTypesAllowed(false)`
2. 設置 `setUserDisabledHdrTypes({DOLBY_VISION, HLG})`
3. 調用 `getHdrCapabilities().getSupportedHdrTypes()`
4. 預期返回：`{HDR10, HDR10_PLUS}` (過濾掉了 DOLBY_VISION 和 HLG)

### 學習要點

1. **跨檔案數據流**：理解數據如何在多個組件間傳遞
2. **Lambda 變量捕獲**：注意 lambda 中使用的變量引用
3. **條件邏輯驗證**：仔細檢查比較條件的正確性
4. **緩存失效機制**：理解 `mInfo.set(null)` 觸發 DisplayInfo 重新計算的作用
