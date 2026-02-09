# Q004 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/content/Intent.java`

**問題代碼**:
```java
public boolean filterEquals(Intent other) {
    if (other == null) {
        return false;
    }
    if (!Objects.equals(this.mAction, other.mAction)) {
        return false;
    }
    if (!Objects.equals(this.mData, other.mData)) {
        return false;
    }
    if (!Objects.equals(this.mType, other.mType)) {
        return false;
    }
    if (!Objects.equals(this.mCategories, other.mCategories)) {
        return false;
    }
    // BUG: 不應該比較 extras
    if (!Objects.equals(this.mExtras, other.mExtras)) {
        return false;
    }
    return true;
}
```

## 根本原因

`filterEquals()` 錯誤地比較了 `mExtras`。根據 API 定義，filterEquals 只應該比較用於 Intent 匹配的字段（action, data, type, categories 等），而不應該比較 extras。

## 修復方案

```java
public boolean filterEquals(Intent other) {
    if (other == null) {
        return false;
    }
    if (!Objects.equals(this.mAction, other.mAction)) {
        return false;
    }
    if (!Objects.equals(this.mData, other.mData)) {
        return false;
    }
    if (!Objects.equals(this.mType, other.mType)) {
        return false;
    }
    if (!Objects.equals(this.mCategories, other.mCategories)) {
        return false;
    }
    // 移除 mExtras 的比較
    return true;
}
```

## 調試過程

1. 測試表明相同 filter 但不同 extras 的 Intent 返回 false
2. 追蹤 filterEquals 方法實現
3. 發現 extras 被錯誤地加入比較

## 涉及檔案

- `frameworks/base/core/java/android/content/Intent.java`

## 難度分析

**Medium** - 需要理解 filterEquals 的語義和 Intent 過濾機制
