# Display-E-Q010 解答

## Root Cause
在 `DisplayInfo.java` 的 `getMode()` 方法中，返回的 mode ID 被錯誤地偏移了 1。

原本：
```java
public Display.Mode getMode() {
    return findMode(modeId);
}
```

被改成：
```java
public Display.Mode getMode() {
    return findMode(modeId + 1);
}
```

這導致返回的 active mode 與實際的 mode ID 不匹配，因此在 supportedModes 陣列中找不到。

## 涉及檔案
- `frameworks/base/core/java/android/view/DisplayInfo.java`

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → 看到 assertTrue 失敗
2. 查看 CTS 測試 → 遍歷 supportedModes 尋找匹配 activeMode
3. 追蹤 `Display.getMode()` → `DisplayInfo.getMode()`
4. 發現 modeId 被偏移

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 DisplayInfo.java |
| 正確定位 bug 位置 | 20% | 找到 getMode() 方法 |
| 理解 root cause | 20% | 解釋 modeId 偏移導致不匹配 |
| 修復方案正確 | 10% | 移除 +1 偏移 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 在 getSupportedModes() 中找問題
- 試圖比較 Mode 對象而不理解 Mode ID 的作用
- 在 LocalDisplayAdapter 或底層找問題
