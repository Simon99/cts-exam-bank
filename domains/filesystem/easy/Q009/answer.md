# Q009 答案解析

## 問題根因
`UUID_DEFAULT` 常量被錯誤地設置為全零 UUID，
而不是 Android 標準定義的內部存儲 UUID。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageManager.java`

## 修復方法
恢復正確的 UUID 值。

## 原始代碼
```java
public static final UUID UUID_DEFAULT = UUID
        .fromString("00000000-0000-0000-0000-000000000000");  // Bug
```

## 修復後代碼
```java
public static final UUID UUID_DEFAULT = UUID
        .fromString("41217664-9172-527a-b3d5-edabb50a7d69");
```

## 知識點
1. `UUID_DEFAULT` 代表設備的默認內部存儲
2. 這個 UUID 是通過 `uuid -v5` 生成的確定性值
3. 它在所有 Android 設備上是相同的
4. 用於標識 `Environment.getDataDirectory()` 對應的存儲

## 調試技巧
1. 對比 CTS 測試中的期望值
2. 檢查 StorageManager 中的常量定義
3. 注意 UUID 是固定值，不會因設備而異
