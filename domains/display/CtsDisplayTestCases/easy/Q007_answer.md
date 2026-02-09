# Display-E-Q007 解答

## Root Cause
在 `DisplayInfo.java` 的 `getLogicalMetrics()` 方法中，`densityDpi` 的賦值被錯誤地設為 0。

原本：
```java
outMetrics.densityDpi = logicalDensityDpi;
```

被改成：
```java
outMetrics.densityDpi = 0;
```

這導致 `DisplayMetrics.densityDpi` 總是返回 0，而非實際的 DPI 值。

## 涉及檔案
- `frameworks/base/core/java/android/view/DisplayInfo.java`

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → 看到 assertTrue 失敗
2. 查看 CTS 測試 → 驗證 densityDpi 在合理範圍內
3. 追蹤 `getMetrics()` → `DisplayInfo.getLogicalMetrics()`
4. 找到 densityDpi 的賦值處

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 DisplayInfo.java |
| 正確定位 bug 位置 | 20% | 找到 densityDpi 賦值處 |
| 理解 root cause | 20% | 解釋 densityDpi 應該來自 logicalDensityDpi |
| 修復方案正確 | 10% | 恢復正確賦值 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 在 DisplayMetrics 類中找問題（那只是數據載體）
- 試圖在 WindowManager 層找問題
- 沒有追蹤 getMetrics 的完整調用鏈
