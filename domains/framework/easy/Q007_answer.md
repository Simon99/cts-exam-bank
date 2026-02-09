# Q007 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
public boolean hasExtra(String name) {
    return mExtras != null && !mExtras.containsKey(name);  // BUG: 多了 !
}
```

## 根本原因

`hasExtra()` 方法中，`containsKey()` 的結果被錯誤地取反。應該是 `mExtras.containsKey(name)` 而不是 `!mExtras.containsKey(name)`。

## 修復方案

```java
public boolean hasExtra(String name) {
    return mExtras != null && mExtras.containsKey(name);
}
```

## 調試技巧

1. putExtra 後 hasExtra 返回 false
2. 說明存在邏輯取反問題
3. 查看 hasExtra() 實現即可發現

## 涉及檔案

- `frameworks/base/core/java/android/content/Intent.java` (單一檔案)

## 難度分析

**Easy** - 簡單的邏輯取反錯誤
