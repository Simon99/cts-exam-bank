# DIS-H004: 答案與解析

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/LocalDisplayAdapter.java`

**方法**：`updateDisplayModesLocked()` (約第 323 行)

## Bug 程式碼

```java
for (int j = 0; j < displayModes.length; j++) {
    SurfaceControl.DisplayMode other = displayModes[j];
    // BUG: j > i instead of j != i
    boolean isAlternative = j > i && other.width == mode.width
            && other.height == mode.height
            && other.peakRefreshRate != mode.peakRefreshRate
            && other.group == mode.group;
    if (isAlternative) {
        alternativeRefreshRates.add(displayModes[j].peakRefreshRate);
    }
}
```

## 正確程式碼

```java
boolean isAlternative = j != i && other.width == mode.width
        && other.height == mode.height
        && other.peakRefreshRate != mode.peakRefreshRate
        && other.group == mode.group;
```

## Bug 分析

### 條件差異

| 條件 | 行為 |
|------|------|
| `j != i` | 雙向：A→B 和 B→A 都會建立 |
| `j > i` | 單向：只有 A→B（當 i < j）|

### 問題結果

```
Modes: [60Hz (i=0), 90Hz (i=1)]

當 i=0 (60Hz):
  j=1 → j > i ✓ → 90Hz 加入 alternatives
  60Hz.alternatives = [90Hz] ✓

當 i=1 (90Hz):
  j=0 → j > i ✗ → 60Hz 不加入
  90Hz.alternatives = [] ✗
```

### 對稱性破壞

```
60Hz → alternativeRefreshRates = [90.0] ✓
90Hz → alternativeRefreshRates = []     ✗

CTS 檢查：90Hz 的 alternatives 應包含 60Hz
結果：FAIL
```

## 修復方案

```diff
-                    boolean isAlternative = j > i && other.width == mode.width
+                    boolean isAlternative = j != i && other.width == mode.width
```

## 關鍵教訓

1. **對稱關係需要雙向處理**：如果 A 和 B 有關係，迴圈邏輯必須處理兩個方向

2. **`j > i` vs `j != i` 的差異**：
   - `j > i`：避免重複處理，但只建立單向關係
   - `j != i`：雙向處理，確保對稱性

3. **CTS 測試驗證邏輯**：測試會檢查圖論的對稱性和傳遞性

## 難度評估：Hard

- **邏輯微妙**：`>` 和 `!=` 的差異容易被忽略
- **需要理解圖論概念**：對稱性、連通性
- **看似合理的「優化」**：`j > i` 看起來像是避免重複的優化
