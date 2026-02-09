# Q003 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
BaseBundle(BaseBundle b, boolean deep) {
    this(b.mClassLoader, 0);
    b.copyInternal(this, false);  // BUG: 應該傳入 deep 參數
}
```

## 根本原因

`BaseBundle` 的深拷貝構造函數中，調用 `copyInternal` 時忽略了 `deep` 參數，硬編碼為 `false`。這導致即使請求深拷貝，實際執行的仍是淺拷貝。

## 修復方案

```java
BaseBundle(BaseBundle b, boolean deep) {
    this(b.mClassLoader, 0);
    b.copyInternal(this, deep);  // 正確：傳入 deep 參數
}
```

## 調試過程

1. 發現修改原始 inner bundle 影響了 deepCopy
2. 說明 inner bundle 是共享的，不是獨立拷貝
3. 追蹤 deepCopy() -> Bundle(this, true) -> BaseBundle(b, deep)
4. 發現 copyInternal 調用時 deep 參數被忽略

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java`
- `frameworks/base/core/java/android/os/Bundle.java`

## 難度分析

**Medium** - 需要理解深拷貝邏輯，追蹤構造函數調用鏈
