# Q008 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
public boolean getBoolean(String key, boolean defaultValue) {
    unparcel();
    Object o = mMap.get(key);
    if (o == null) {
        return false;  // BUG: 應該返回 defaultValue
    }
    try {
        return (Boolean) o;
    } catch (ClassCastException e) {
        typeWarning(key, o, "Boolean", defaultValue, e);
        return defaultValue;
    }
}
```

## 根本原因

當 key 不存在時，方法返回硬編碼的 `false` 而不是傳入的 `defaultValue`。

## 修復方案

```java
public boolean getBoolean(String key, boolean defaultValue) {
    unparcel();
    Object o = mMap.get(key);
    if (o == null) {
        return defaultValue;  // 正確：返回預設值
    }
    try {
        return (Boolean) o;
    } catch (ClassCastException e) {
        typeWarning(key, o, "Boolean", defaultValue, e);
        return defaultValue;
    }
}
```

## 調試技巧

1. 空 Bundle 調用 `getBoolean(key, true)` 返回 false
2. 預設值 true 沒有生效
3. 查看 getBoolean 的 null 處理邏輯

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java` (單一檔案)

## 難度分析

**Easy** - 與 Q002 類似的 defaultValue 問題
