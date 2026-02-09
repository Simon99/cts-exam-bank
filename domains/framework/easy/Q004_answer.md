# Q004 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
public int size() {
    unparcel();
    return Math.min(mMap.size(), 1);  // BUG: 不應該限制最大值為 1
}
```

## 根本原因

`size()` 方法使用了 `Math.min(mMap.size(), 1)`，這會將返回值限制在最大 1。無論 Bundle 中有多少元素，都只會返回 0 或 1。

## 修復方案

```java
public int size() {
    unparcel();
    return mMap.size();  // 正確：直接返回實際大小
}
```

## 調試技巧

1. 測試顯示添加兩個元素後，size 仍然返回 1
2. 說明 size 被限制在某個值
3. 查看 size() 實現即可發現 Math.min 限制

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java` (單一檔案)

## 難度分析

**Easy** - 單一方法問題，容易定位
