# Q005 提示

## 提示 1：數據流追蹤
追蹤 `userDisabledHdrTypes` 的完整傳遞路徑：
```
DisplayManagerService.setAreUserDisabledHdrTypesAllowedInternal()
    ↓
LogicalDisplay.setUserDisabledHdrTypes()
    ↓
DisplayInfo.userDisabledHdrTypes
    ↓
Display.getHdrCapabilities() [過濾邏輯]
```

## 提示 2：變量混淆
在 `setAreUserDisabledHdrTypesAllowedInternal()` 中，注意這段代碼：
```java
int userDisabledHdrTypes[] = {};
if (!mAreUserDisabledHdrTypesAllowed) {
    userDisabledHdrTypes = mUserDisabledHdrTypes;
}
int[] finalUserDisabledHdrTypes = userDisabledHdrTypes;
```
問問自己：lambda 中應該使用哪個變量？

## 提示 3：比較邏輯
在 `LogicalDisplay.setUserDisabledHdrTypes()` 中：
```java
if (mUserDisabledHdrTypes != userDisabledHdrTypes) {
```
這是引用比較 (`!=`) 還是內容比較？這個條件什麼時候為 true？

## 提示 4：緩存失效
`mInfo.set(null)` 的作用是什麼？如果這行代碼沒有被執行，會發生什麼？

## 提示 5：關鍵線索
Bug 可能在於：
1. DisplayManagerService 傳遞了錯誤的數組
2. LogicalDisplay 的條件判斷邏輯有問題
3. 或者兩者都有問題
