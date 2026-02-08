# M-Q005: 答案

## Bug 位置

**檔案:** `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

**問題:** 建立 VirtualDisplayDevice 時，HDR capabilities 初始化邏輯不一致

## 根因分析

在 `VirtualDisplayAdapter` 建立 VirtualDisplayDevice 時，有一段初始化 HDR capabilities 的邏輯：

### 正確程式碼：
```java
private HdrCapabilities createHdrCapabilities() {
    if (!mSupportsHdr) {
        // 不支援 HDR 時，所有值都應該是預設值
        return new HdrCapabilities(
            new int[]{},  // supportedHdrTypes = empty
            0.0f,         // maxLuminance = 0
            0.0f,         // maxAverageLuminance = 0
            0.0f          // minLuminance = 0
        );
    }
    // 支援 HDR 的情況...
}
```

### Bug 版本：
```java
private HdrCapabilities createHdrCapabilities() {
    if (!mSupportsHdr) {
        // [BUG] supportedHdrTypes 為空但 luminance 有值，造成不一致
        return new HdrCapabilities(
            new int[]{},  // supportedHdrTypes = empty
            500.0f,       // maxLuminance = 500 (應該是 0)
            400.0f,       // maxAverageLuminance = 400 (應該是 0)
            0.0f          // minLuminance = 0
        );
    }
    // ...
}
```

### 邏輯分析

HDR capabilities 的一致性規則：
- 如果 `supportedHdrTypes` 為空（不支援任何 HDR 格式），那麼 luminance 值應該都是 0
- 如果有 HDR 支援，才應該有非零的 luminance 值

**正確邏輯：**
- 不支援 HDR → types=[], luminance=0.0

**Bug 邏輯：**
- 不支援 HDR → types=[], luminance=500.0（矛盾！）

CTS 測試驗證了這個一致性，所以失敗了。

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java
@@ -xxx,8 +xxx,8 @@ class VirtualDisplayAdapter {
     private HdrCapabilities createHdrCapabilities() {
         if (!mSupportsHdr) {
             return new HdrCapabilities(
                 new int[]{},
-                500.0f,
-                400.0f,
+                0.0f,
+                0.0f,
                 0.0f
             );
         }
```

## 診斷技巧

1. **理解錯誤訊息** - types=[] 但 luminance≠0，明顯不一致
2. **追蹤 VirtualDisplay 建立流程** - 從 DisplayManager → VirtualDisplayAdapter
3. **在 createHdrCapabilities 加 log** - 確認初始化時的值
4. **檢查一致性邏輯** - 發現 !mSupportsHdr 分支的 luminance 值錯誤

## 評分標準

| 項目 | 分數 |
|------|------|
| 理解 HDR capabilities 一致性規則 | 20% |
| 找到 VirtualDisplayAdapter | 25% |
| 定位到 createHdrCapabilities 方法 | 30% |
| 識別出 luminance 初始化錯誤 | 25% |
