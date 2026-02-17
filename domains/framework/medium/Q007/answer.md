# Q007 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
public Set<String> keySet() {
    unparcel();
    return mMap.keySet();  // BUG: 直接返回內部 map 的 keySet
}
```

## 根本原因

`keySet()` 直接返回 `mMap.keySet()`，這是內部 ArrayMap 的 key 視圖。對這個集合的修改會直接影響 mMap，從而影響 Bundle 的內容。

## 修復方案

```java
public Set<String> keySet() {
    unparcel();
    return new HashSet<>(mMap.keySet());  // 返回副本
    // 或者
    // return Collections.unmodifiableSet(mMap.keySet());  // 返回不可修改視圖
}
```

## 調試過程

1. 通過 keySet().remove() 可以影響 Bundle 內容
2. 說明 keySet 返回的是內部集合的直接引用
3. 追蹤 keySet() 方法實現
4. 發現直接返回 mMap.keySet()

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java`

## 難度分析

**Medium** - 需要理解集合視圖和防禦性拷貝
