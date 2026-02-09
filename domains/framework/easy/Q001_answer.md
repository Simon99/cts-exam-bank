# Q001 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
public String getString(@Nullable String key) {
    unparcel();
    final Object o = mMap.get(key);
    try {
        return null;  // BUG: 應該返回 (String) o
    } catch (ClassCastException e) {
        typeWarning(key, o, "String", e);
        return null;
    }
}
```

## 根本原因

`getString()` 方法中，在獲取到值後直接返回 `null`，而不是返回實際的值。這是一個簡單的返回值錯誤。

## 修復方案

```java
public String getString(@Nullable String key) {
    unparcel();
    final Object o = mMap.get(key);
    try {
        return (String) o;  // 正確：返回實際值
    } catch (ClassCastException e) {
        typeWarning(key, o, "String", e);
        return null;
    }
}
```

## 調試技巧

1. 從 CTS fail log 可以看到 `expected:<test_value> but was:<null>`
2. 這明確指出 `getString()` 返回了 null
3. 直接查看 `BaseBundle.getString()` 方法即可發現問題

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java` (單一檔案)

## 難度分析

**Easy** - 讀 CTS fail log 就能定位，單一檔案修改
