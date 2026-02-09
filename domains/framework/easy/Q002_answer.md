# Q002 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
public int getInt(String key, int defaultValue) {
    unparcel();
    Object o = mMap.get(key);
    if (o == null) {
        return 0;  // BUG: 應該返回 defaultValue
    }
    try {
        return (Integer) o;
    } catch (ClassCastException e) {
        typeWarning(key, o, "Integer", defaultValue, e);
        return defaultValue;
    }
}
```

## 根本原因

當 key 不存在（`o == null`）時，方法返回固定值 `0` 而不是傳入的 `defaultValue`。這違反了方法的設計契約。

## 修復方案

```java
public int getInt(String key, int defaultValue) {
    unparcel();
    Object o = mMap.get(key);
    if (o == null) {
        return defaultValue;  // 正確：返回預設值
    }
    try {
        return (Integer) o;
    } catch (ClassCastException e) {
        typeWarning(key, o, "Integer", defaultValue, e);
        return defaultValue;
    }
}
```

## 調試技巧

1. 測試第一行就失敗：`assertEquals(100, mBundle.getInt(KEY1, 100))`
2. 此時 Bundle 是空的，應該返回 defaultValue=100
3. 但實際返回了 0，說明 null 處理邏輯有問題

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java` (單一檔案)

## 難度分析

**Easy** - 錯誤訊息清楚指出預設值未生效
