# Q005 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/Bundle.java`

**問題代碼**:
```java
public void putAll(Bundle bundle) {
    unparcel();
    bundle.unparcel();
    mOwnsLazyValues = false;
    bundle.mOwnsLazyValues = false;
    mMap.clear();  // BUG: 不應該清空原有數據
    mMap.putAll(bundle.mMap);
    // ... flag 處理
}
```

## 根本原因

`putAll()` 方法在合併前錯誤地調用了 `mMap.clear()`，清空了原有的數據。正確的行為應該是直接合併，保留原有數據。

## 修復方案

```java
public void putAll(Bundle bundle) {
    unparcel();
    bundle.unparcel();
    mOwnsLazyValues = false;
    bundle.mOwnsLazyValues = false;
    // 移除 mMap.clear();
    mMap.putAll(bundle.mMap);
    // ... flag 處理
}
```

## 調試過程

1. putAll 後只有來自 other 的數據
2. 原始數據 "key1" 丟失了
3. 說明 putAll 前有清空操作
4. 追蹤 putAll 實現找到 clear() 調用

## 涉及檔案

- `frameworks/base/core/java/android/os/Bundle.java`
- `frameworks/base/core/java/android/os/BaseBundle.java`（理解 mMap）

## 難度分析

**Medium** - 需要分析合併邏輯，理解錯誤的清空操作
