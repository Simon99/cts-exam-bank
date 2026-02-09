# Q006 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
@Override
public Object clone() {
    Intent intent = new Intent(this, false);  // shallow copy
    intent.mExtras = this.mExtras;  // BUG: 應該拷貝 extras，而不是共享
    return intent;
}
```

## 根本原因

`clone()` 方法直接將原始 Intent 的 `mExtras` Bundle 賦值給 clone，而不是創建新的 Bundle 副本。這導致兩個 Intent 共享同一個 Bundle 對象。

## 修復方案

```java
@Override
public Object clone() {
    Intent intent = new Intent(this, false);
    if (this.mExtras != null) {
        intent.mExtras = new Bundle(this.mExtras);  // 正確：創建 Bundle 副本
    }
    return intent;
}
```

## 調試過程

1. 修改 clone 的 extra 影響了原始 Intent
2. 說明 mExtras 是共享的
3. 追蹤 clone() 方法
4. 發現 mExtras 直接賦值而非拷貝

## 涉及檔案

- `frameworks/base/core/java/android/content/Intent.java`
- `frameworks/base/core/java/android/os/Bundle.java`（理解拷貝）

## 難度分析

**Medium** - 需要理解淺拷貝和深拷貝的區別
