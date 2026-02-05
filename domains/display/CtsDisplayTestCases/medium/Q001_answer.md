# M-Q001: 答案

## Bug 位置

**檔案:** `frameworks/base/core/java/android/view/DisplayInfo.java`

**問題:** `writeToParcel()` 中的序列化順序錯誤

## 根因分析

DisplayInfo 的 `writeToParcel()` 和 `readFromParcel()` 順序不一致：

### 原始正確順序（readFromParcel）:
```java
colorMode = source.readInt();
// ... supportedColorModes
hdrCapabilities = source.readParcelable(...);
```

### Bug 版本（writeToParcel）:
```java
dest.writeParcelable(hdrCapabilities, flags);  // ← 被移到前面
dest.writeInt(colorMode);
// ... supportedColorModes
```

當 App 呼叫 `Display.getHdrCapabilities()` 或其他需要 DisplayInfo 的 API 時：
1. DisplayManagerService 將 DisplayInfo 序列化（writeToParcel）
2. App 端反序列化（readFromParcel）
3. 因為順序不一致，讀取的資料錯亂
4. 嘗試用 int 值當作 Parcelable → Crash

## 修復方案

```diff
--- a/core/java/android/view/DisplayInfo.java
+++ b/core/java/android/view/DisplayInfo.java
@@ -611,12 +611,12 @@ public final class DisplayInfo implements Parcelable {
         for (int i = 0; i < supportedModes.length; i++) {
             supportedModes[i].writeToParcel(dest, flags);
         }
-        dest.writeParcelable(hdrCapabilities, flags);  // [BUG] moved before colorMode
         dest.writeInt(colorMode);
         dest.writeInt(supportedColorModes.length);
         for (int i = 0; i < supportedColorModes.length; i++) {
             dest.writeInt(supportedColorModes[i]);
         }
+        dest.writeParcelable(hdrCapabilities, flags);
         dest.writeBoolean(minimalPostProcessingSupported);
```

## 診斷技巧

1. **Process crashed 通常是 Parcel 問題** - 跨進程通訊時序列化錯誤會導致崩潰
2. **對比 writeToParcel 和 readFromParcel** - 順序必須完全一致
3. **使用 logcat 找 Parcel 相關錯誤**:
   ```bash
   adb logcat | grep -E "Parcel|unmarshall|BadParcelable"
   ```

## 評分標準

| 項目 | 分數 |
|------|------|
| 正確識別是 Parcel 問題 | 30% |
| 找到 DisplayInfo.java | 30% |
| 定位到序列化順序錯誤 | 30% |
| 提供正確修復 | 10% |
