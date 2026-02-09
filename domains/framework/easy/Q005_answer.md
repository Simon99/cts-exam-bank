# Q005 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
public @Nullable String getStringExtra(String name) {
    return mExtras == null ? null : null;  // BUG: 應該調用 mExtras.getString(name)
}
```

## 根本原因

`getStringExtra()` 方法在 mExtras 不為 null 時，仍然返回 null，而不是從 mExtras Bundle 中獲取實際值。

## 修復方案

```java
public @Nullable String getStringExtra(String name) {
    return mExtras == null ? null : mExtras.getString(name);
}
```

## 調試技巧

1. putExtra 後 getStringExtra 仍然返回 null
2. 說明 get 方法沒有正確讀取 mExtras
3. 直接查看 Intent.getStringExtra() 實現

## 涉及檔案

- `frameworks/base/core/java/android/content/Intent.java` (單一檔案)

## 難度分析

**Easy** - 單行方法，錯誤明顯
