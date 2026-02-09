# Display-E-Q006 解答

## Root Cause
`WindowManager.getDefaultDisplay().getDisplayId()` 返回了 -1 而非預期的 0（DEFAULT_DISPLAY）。

問題在 `DisplayManagerService.java` 的 `getDisplayIdForWindow()` 方法中，當找不到對應的 window 時，錯誤地返回了 `Display.INVALID_DISPLAY`（-1）而不是 `DEFAULT_DISPLAY`（0）作為 fallback。

原本：
```java
if (window == null) {
    return DEFAULT_DISPLAY;
}
```

被改成：
```java
if (window == null) {
    return Display.INVALID_DISPLAY;
}
```

## 涉及檔案
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → 看到 `expected:<0> but was:<-1>`
2. 搜索 `DEFAULT_DISPLAY` 和 `INVALID_DISPLAY` 常量
3. 追蹤 `getDefaultDisplay()` → `WindowManager` → `DisplayManagerService`
4. 找到返回 -1 的條件分支

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 DisplayManagerService.java |
| 正確定位 bug 位置 | 20% | 找到 fallback 返回值的修改 |
| 理解 root cause | 20% | 解釋 INVALID_DISPLAY vs DEFAULT_DISPLAY |
| 修復方案正確 | 10% | 改回 DEFAULT_DISPLAY |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 在 WindowManager 層找問題（問題在 DisplayManager）
- 試圖修改 CTS 測試（不合理）
- 不理解 Display ID 的意義
