# Q002 答案解析

## 問題根因
`isRemovable()` 方法中使用了邏輯非運算符 `!`，導致返回值被反轉。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageVolume.java`

## 修復方法
移除錯誤的 `!` 運算符。

## 原始代碼
```java
public boolean isRemovable() {
    return !mRemovable;  // Bug: 邏輯反轉
}
```

## 修復後代碼
```java
public boolean isRemovable() {
    return mRemovable;
}
```

## 知識點
1. Emulated storage（如 `/storage/emulated/0`）是不可移除的
2. 可移除存儲通常指 SD 卡或 USB 存儲
3. 邏輯運算符錯誤是常見的 bug 類型

## 調試技巧
1. 對比 emulated 和 removable 的預期行為
2. 檢查布爾值返回邏輯
3. 單元測試可以快速發現這類問題
