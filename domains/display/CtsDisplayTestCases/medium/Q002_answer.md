# M-Q002: 答案

## Bug 位置

**檔案:** `frameworks/base/core/java/android/view/Display.java`

**問題:** `Mode.matches()` 方法中 width 和 height 參數比較交換

## 根因分析

Mode.equals() 內部呼叫 matches() 來比較寬高：

```java
@Override
public boolean equals(@Nullable Object other) {
    // ...
    return mModeId == that.mModeId
            && matches(that.mWidth, that.mHeight, that.mPeakRefreshRate)  // 這裡！
            && Arrays.equals(mAlternativeRefreshRates, that.mAlternativeRefreshRates)
            && Arrays.equals(mSupportedHdrTypes, that.mSupportedHdrTypes);
}
```

### Bug 版本（matches）:
```java
public boolean matches(int width, int height, float refreshRate) {
    return mWidth == height &&   // BUG: 應該是 mWidth == width
            mHeight == width &&  // BUG: 應該是 mHeight == height
            Float.floatToIntBits(mPeakRefreshRate) == Float.floatToIntBits(refreshRate);
}
```

### 為什麼 toString() 顯示一樣？

因為 toString() 直接輸出 mWidth 和 mHeight 的值，不經過 matches()：
```java
@Override
public String toString() {
    return new StringBuilder("{")
            .append("width=").append(mWidth)   // 直接輸出
            .append(", height=").append(mHeight)
            // ...
}
```

### 為什麼只有非正方形螢幕會失敗？

如果 width == height（正方形），即使交換也不影響結果。
但對於 width=182, height=162 的 Mode：
- 正確比較: 182==182 && 162==162 → true
- Bug 比較: 182==162 && 162==182 → false

## 修復方案

```diff
--- a/core/java/android/view/Display.java
+++ b/core/java/android/view/Display.java
@@ -2260,8 +2260,8 @@ public final class Display {
         @TestApi
         public boolean matches(int width, int height, float refreshRate) {
-            return mWidth == height &&
-                    mHeight == width &&
+            return mWidth == width &&
+                    mHeight == height &&
                     Float.floatToIntBits(mPeakRefreshRate) == Float.floatToIntBits(refreshRate);
         }
```

## 診斷技巧

1. **toString() 相同但 equals() 失敗** → 立刻懷疑 equals() 實現
2. **檢查 equals() 調用鏈** → 發現它用了 matches()
3. **比對參數名和成員變數** → 發現 width/height 交換

## 評分標準

| 項目 | 分數 |
|------|------|
| 識別 toString/equals 不一致 | 20% |
| 找到 equals() 調用 matches() | 20% |
| 定位 matches() 中的參數交換 | 40% |
| 提供正確修復 | 20% |
