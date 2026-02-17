# Q010 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
public @NonNull Intent setAction(@Nullable String action) {
    // mAction = action;  // BUG: 沒有實際保存 action
    return this;
}
```

## 根本原因

`setAction()` 方法沒有將傳入的 action 保存到 `mAction` 成員變量，導致 `getAction()` 永遠返回初始值 null。

## 修復方案

```java
public @NonNull Intent setAction(@Nullable String action) {
    mAction = action;
    return this;
}
```

## 調試技巧

1. setAction 後 getAction 返回 null
2. 說明 action 沒有被保存
3. 查看 setAction() 實現

## 涉及檔案

- `frameworks/base/core/java/android/content/Intent.java` (單一檔案)

## 難度分析

**Easy** - setter 方法沒有實際賦值
