# M-Q003: 答案

## Bug 位置

**檔案:** `frameworks/base/core/java/android/view/Display.java`

**問題:** `getHdrCapabilities()` 方法中的過濾邏輯條件反轉

## 根因分析

在 `getHdrCapabilities()` 方法中，有一段過濾 userDisabledHdrTypes 的邏輯：

### 正確程式碼：
```java
for (int supportedType : getMode().getSupportedHdrTypes()) {
    if (!contains(mDisplayInfo.userDisabledHdrTypes, supportedType)) {
        enabledTypesSet.add(supportedType);  // 不在 disabled 列表中，加入 enabled
    }
}
```

### Bug 版本：
```java
for (int supportedType : getMode().getSupportedHdrTypes()) {
    if (contains(mDisplayInfo.userDisabledHdrTypes, supportedType)) {  // 少了 !
        enabledTypesSet.add(supportedType);  // 在 disabled 列表中，反而加入 enabled
    }
}
```

### 邏輯分析

假設：
- 支援的 HDR types: [DOLBY_VISION(1), HDR10(2), HLG(3), HDR10_PLUS(4)]
- 用戶禁用的 types: [DOLBY_VISION(1), HLG(3)]

**正確邏輯：**
- 返回 [HDR10(2), HDR10_PLUS(4)]（不在禁用列表中的）

**Bug 邏輯：**
- 返回 [DOLBY_VISION(1), HLG(3)]（在禁用列表中的）

所以測試期望得到 HDR10(2)，但實際得到 DOLBY_VISION(1)。

## 修復方案

```diff
--- a/frameworks/base/core/java/android/view/Display.java
+++ b/frameworks/base/core/java/android/view/Display.java
@@ -1249,7 +1249,7 @@ public final class Display {
         } else {
             ArraySet<Integer> enabledTypesSet = new ArraySet<>();
             for (int supportedType : getMode().getSupportedHdrTypes()) {
-                if (contains(mDisplayInfo.userDisabledHdrTypes, supportedType)) {
+                if (!contains(mDisplayInfo.userDisabledHdrTypes, supportedType)) {
                     enabledTypesSet.add(supportedType);
                 }
             }
```

## 診斷技巧

1. **從測試名稱理解預期行為** - "UserDisabledFormatsAreNotAllowed" 明確說明禁用的格式不應該返回
2. **從錯誤訊息定位問題範圍** - expected:<2> but was:<1> 說明返回了錯誤的 HDR type
3. **搜索相關代碼** - 在 Display.java 搜索 "userDisabledHdrTypes" 或 "getHdrCapabilities"
4. **檢查條件邏輯** - 發現 contains() 前面少了 `!`

## 評分標準

| 項目 | 分數 |
|------|------|
| 理解測試意圖（過濾禁用格式）| 20% |
| 找到 getHdrCapabilities() 方法 | 20% |
| 定位到 contains() 條件判斷 | 40% |
| 識別出缺少 `!` 運算符 | 20% |
