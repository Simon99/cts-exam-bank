# Q009 解答：getDisplayInfoLocked() 條件判斷反轉錯誤

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`  
**方法**：`getDisplayInfoLocked()`（約第 252 行）

## 問題程式碼

```java
public DisplayInfo getDisplayInfoLocked() {
    if (mInfo.get() != null) {  // ← BUG: 條件反轉
        DisplayInfo info = new DisplayInfo();
        copyDisplayInfoFields(info, mBaseDisplayInfo, mOverrideDisplayInfo,
                WM_OVERRIDE_FIELDS);
        mInfo.set(info);
    }
    return mInfo.get();
}
```

## Bug 分析

### 問題類型
**條件判斷反轉 (Condition Inversion)**

### 錯誤行為

| 情境 | 正確行為 | 錯誤行為 |
|------|---------|---------|
| 首次呼叫 (mInfo == null) | 創建並快取 DisplayInfo | **跳過創建，返回 null** |
| 後續呼叫 (mInfo != null) | 直接返回快取值 | **重新創建，浪費資源** |

### 為什麼導致 NullPointerException

1. 系統啟動時首次呼叫 `getDisplayInfoLocked()`
2. 此時 `mInfo.get()` 返回 `null`
3. 錯誤的條件 `!= null` 為 false，不進入 if 區塊
4. 直接返回 `mInfo.get()`，即 `null`
5. 呼叫端對 null 進行操作，觸發 NPE

## 正確程式碼

```java
public DisplayInfo getDisplayInfoLocked() {
    if (mInfo.get() == null) {  // ✓ 正確：快取為空時初始化
        DisplayInfo info = new DisplayInfo();
        copyDisplayInfoFields(info, mBaseDisplayInfo, mOverrideDisplayInfo,
                WM_OVERRIDE_FIELDS);
        mInfo.set(info);
    }
    return mInfo.get();
}
```

## 修復 Patch

```diff
-        if (mInfo.get() != null) {
+        if (mInfo.get() == null) {
```

## 快取模式解析

這是一個典型的 **Lazy Initialization（延遲初始化）** 模式：

```
檢查快取是否為空？
   ↓ 是（== null）
創建新物件，存入快取
   ↓
返回快取的物件
```

條件反轉會破壞整個模式：
- 該初始化時不初始化 → 返回 null
- 不該初始化時反覆初始化 → 浪費記憶體

## 影響範圍

- 所有依賴 `Display.getDisplayInfo()` 的上層 API
- `Display.getName()`, `Display.getRefreshRate()`, `Display.getSize()` 等
- 任何需要獲取顯示屬性的應用程式

## 學習重點

1. **條件判斷要仔細**：`==` 和 `!=` 的混淆是常見錯誤
2. **Lazy Initialization 模式**：理解「為空才初始化」的邏輯
3. **快取邏輯**：首次呼叫與後續呼叫應該有不同的行為路徑
