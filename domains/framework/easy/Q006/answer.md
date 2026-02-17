# Q006 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
public boolean isEmpty() {
    unparcel();
    return true;  // BUG: 應該返回 mMap.isEmpty()
}
```

## 根本原因

`isEmpty()` 方法始終返回 `true`，而不是檢查 mMap 的實際狀態。這導致無論 Bundle 中有多少數據，都被認為是空的。

## 修復方案

```java
public boolean isEmpty() {
    unparcel();
    return mMap.isEmpty();
}
```

## 調試技巧

1. put 數據後 isEmpty 仍然返回 true
2. 說明 isEmpty 沒有正確檢查 mMap
3. 直接查看 isEmpty() 實現

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java` (單一檔案)

## 難度分析

**Easy** - 單行硬編碼錯誤
