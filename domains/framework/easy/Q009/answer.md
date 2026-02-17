# Q009 答案解析

## Bug 位置

**檔案**: `frameworks/base/core/java/android/os/BaseBundle.java`

**問題代碼**:
```java
void remove(String key) {
    unparcel();
    // mMap.remove(key);  // BUG: 這行被註釋掉了
}
```

## 根本原因

`remove()` 方法中，實際執行刪除的 `mMap.remove(key)` 被註釋掉或刪除了，導致 remove 操作實際上什麼都沒做。

## 修復方案

```java
void remove(String key) {
    unparcel();
    mMap.remove(key);
}
```

## 調試技巧

1. remove 後 containsKey 仍返回 true
2. 說明 remove 沒有實際刪除數據
3. 查看 remove() 方法實現

## 涉及檔案

- `frameworks/base/core/java/android/os/BaseBundle.java` (單一檔案)

## 難度分析

**Easy** - 方法體缺少關鍵操作
