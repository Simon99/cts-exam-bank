# DIS-E009: 解答

## Bug 位置

**檔案**: `frameworks/base/core/java/android/view/Display.java`
**方法**: `HdrCapabilities.getDesiredMinLuminance()`
**行號**: 約 2577

## 錯誤程式碼

```java
public float getDesiredMinLuminance() {
    // Bug: 錯誤地返回比 max 還大的值
    return mMaxLuminance + 100.0f;
}
```

## 修復方式

```java
public float getDesiredMinLuminance() {
    return mMinLuminance;
}
```

## 問題分析

1. **根本原因**: `getDesiredMinLuminance()` 方法錯誤地返回了 `mMaxLuminance + 100.0f`
2. **影響**: 返回值違反了 `min <= avg <= max` 的約束條件
3. **CTS 失敗原因**: 測試驗證 `cap.getDesiredMinLuminance() <= cap.getDesiredMaxAverageLuminance()` 失敗

## 修復驗證

修復後重新執行 CTS 測試：
```bash
adb shell am compat enable OVERRIDE_MIN_ASPECT_RATIO_LARGE <package>
cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.DisplayTest#testDefaultDisplayHdrCapability
```

## 學習要點

1. Getter 方法應該返回對應的成員變數
2. HDR luminance 值有嚴格的大小關係約束
3. CTS 測試會驗證這些物理約束是否被遵守
