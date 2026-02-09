# Q009 答案

## Bug 描述

在 `Display.Mode.equals()` 方法中，`mModeId` 的比較使用了錯誤的運算符。

## 問題代碼

```java
// 位置：Display.java 第 2328 行
return mModeId != that.mModeId  // ❌ 錯誤：使用了 !=
        && matches(that.mWidth, that.mHeight, that.mPeakRefreshRate)
        && Arrays.equals(mAlternativeRefreshRates, that.mAlternativeRefreshRates)
        && Arrays.equals(mSupportedHdrTypes, that.mSupportedHdrTypes);
```

## 修復代碼

```java
return mModeId == that.mModeId  // ✅ 正確：應該使用 ==
        && matches(that.mWidth, that.mHeight, that.mPeakRefreshRate)
        && Arrays.equals(mAlternativeRefreshRates, that.mAlternativeRefreshRates)
        && Arrays.equals(mSupportedHdrTypes, that.mSupportedHdrTypes);
```

## 原因分析

1. **`&&` 連接的條件**：
   - 所有條件必須為 `true`，整個表達式才為 `true`
   - 只要有一個條件為 `false`，整個表達式為 `false`

2. **`!=` vs `==` 的影響**：
   - 當比較兩個相同的 Mode（相同 mModeId）時：
     - `mModeId != that.mModeId` → `false`（因為它們相等，所以 != 為 false）
     - 由於第一個條件為 `false`，整個 `&&` 表達式必然為 `false`
   - 結果：**兩個相同的 Mode 永遠不會被認為相等**

3. **測試失敗原因**：
   - `activeMode` 和 `supportedModes[i]` 即使是相同的 Mode
   - `equals()` 仍然返回 `false`
   - 循環結束後 `activeModeIsSupported` 保持 `false`

## 測試驗證

```bash
atest android.display.cts.DisplayTest#testActiveModeIsSupportedModesOnDefaultDisplay
```

## 相關知識

1. **Java equals() 標準實現模式**：
   ```java
   @Override
   public boolean equals(Object other) {
       if (this == other) return true;           // 1. identity check
       if (!(other instanceof MyClass)) return false;  // 2. type check
       MyClass that = (MyClass) other;
       return field1 == that.field1              // 3. field comparison
           && field2.equals(that.field2);
   }
   ```

2. **常見錯誤**：
   - `==` 和 `!=` 混淆
   - 在 `&&` 表達式中誤用 `!=`
   - 忘記 identity check
