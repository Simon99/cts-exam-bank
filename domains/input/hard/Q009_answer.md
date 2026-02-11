# Q009 Answer

## 正確答案：A

## 解析

### 問題根因
`hasModifiers()` 錯誤地使用 `==` 比較，要求 metaState 完全等於 modifiers，而非檢查 modifiers 是否為 metaState 的子集。

### 位元運算分析

**測試數據：**
```
metaState = 0x00001003 (CTRL | SHIFT | ALT)
modifiers = 0x00001001 (CTRL | SHIFT)
```

**Bug 程式碼（使用 ==）：**
```java
public boolean hasModifiers(int modifiers) {
    return getMetaState() == modifiers;  // BUG
}
// 0x00001003 == 0x00001001 → false (Wrong!)
```

**正確程式碼（使用位元 AND）：**
```java
public boolean hasModifiers(int modifiers) {
    return (getMetaState() & modifiers) == modifiers;
}
// (0x00001003 & 0x00001001) = 0x00001001
// 0x00001001 == 0x00001001 → true (Correct!)
```

### 測試案例驗證

| 測試 | metaState | modifiers | == 結果 | 正確結果 |
|------|-----------|-----------|---------|----------|
| 單鍵 | 0x1003 | 0x1000 | false | true |
| 子集 | 0x1003 | 0x1001 | false | true |
| 完全匹配 | 0x1003 | 0x1003 | true | true |

### 為什麼其他選項不對

**B) `(metaState & modifiers) != 0`**
- 這會檢查「任一」修飾鍵，不是「所有」
- 測試 1 應該會返回 true（因為有交集）
- 但錯誤顯示返回 false

**C) `(metaState | modifiers) == modifiers`**
- `0x1003 | 0x1001 = 0x1003`
- `0x1003 == 0x1001` → false
- 結果相同，但這個邏輯沒有意義

**D) 正規化問題**
- 如果是正規化問題，單一修飾鍵也應該失敗
- 但測試 2 顯示單一修飾鍵是正確的

### 關鍵洞察
位元運算的語義必須精確：
- `(a & b) == b` → b 的所有位元都在 a 中（子集檢查）
- `a == b` → 完全相等
- `(a & b) != 0` → 有任何交集
