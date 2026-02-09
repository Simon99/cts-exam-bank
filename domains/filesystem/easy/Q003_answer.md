# Q003 答案解析

## 問題根因
`getState()` 方法被錯誤地硬編碼返回 `Environment.MEDIA_UNMOUNTED`，
而不是返回實際的 `mState` 變量。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageVolume.java`

## 修復方法
將返回值從硬編碼的常量改為 `mState` 成員變量。

## 原始代碼
```java
public String getState() {
    return Environment.MEDIA_UNMOUNTED;  // Bug: 硬編碼
}
```

## 修復後代碼
```java
public String getState() {
    return mState;
}
```

## 知識點
1. 存儲卷狀態包括：MEDIA_MOUNTED, MEDIA_UNMOUNTED, MEDIA_CHECKING 等
2. 狀態應該反映實際的掛載情況
3. 硬編碼常量是常見的開發錯誤

## 調試技巧
1. 確認設備存儲已正常掛載
2. 檢查 `getState()` 返回值與預期的差異
3. 追蹤 `mState` 變量的賦值流程
