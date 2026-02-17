# Q003 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
public boolean containsKey(String key) {
    unparcel();
    return !mMap.containsKey(key);  // BUG: 多了 ! 取反
}
```

## 根本原因

`containsKey()` 方法的返回值被錯誤地取反了。原本應該直接返回 `mMap.containsKey(key)` 的結果，但加了 `!` 導致邏輯完全相反。

## 修復方案

```java
public boolean containsKey(String key) {
    unparcel();
    return mMap.containsKey(key);  // 正確：直接返回結果
}
```

## 調試技巧

1. 測試顯示 put 後 containsKey 返回 false
2. 這是最簡單的邏輯錯誤 - 布林值取反
3. 直接查看 containsKey 實現即可發現

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java` (單一檔案)

## 難度分析

**Easy** - 單行邏輯錯誤，非常容易定位
