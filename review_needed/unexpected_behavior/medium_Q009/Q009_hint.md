# Q005 提示

## 提示 1（初級）
問題出在 `Display.Mode` 類的 `equals()` 方法中。這個方法用於比較兩個顯示模式是否相等。

## 提示 2（中級）
檢查 `equals()` 方法的返回語句。所有條件都必須為 `true` 才能返回 `true`。思考：
- 當兩個 `Mode` 對象具有相同的 `mModeId` 時，第一個比較條件應該是什麼？
- 使用了正確的比較運算符嗎？

## 提示 3（進階）
問題在於 `mModeId` 的比較使用了 `!=` 而不是 `==`：
```java
return mModeId != that.mModeId  // BUG: 應該使用 ==
        && matches(...)
        && Arrays.equals(...)
        && Arrays.equals(...);
```

這導致：
1. 當兩個模式具有相同的 `mModeId` 時，`mModeId != that.mModeId` 返回 `false`
2. 由於 `&&` 短路求值，整個表達式立即返回 `false`
3. 因此，相等的模式反而被判定為不相等

## 修復方案
將 `!=` 改為 `==`：
```java
return mModeId == that.mModeId
        && matches(that.mWidth, that.mHeight, that.mPeakRefreshRate)
        && Arrays.equals(mAlternativeRefreshRates, that.mAlternativeRefreshRates)
        && Arrays.equals(mSupportedHdrTypes, that.mSupportedHdrTypes);
```

## 相關文件
- `frameworks/base/core/java/android/view/Display.java`（第 2320-2333 行）
