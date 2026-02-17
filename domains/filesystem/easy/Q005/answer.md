# Q005 答案解析

## 問題根因
`StorageManager.isObbMounted()` 方法被錯誤地硬編碼返回 `false`，
沒有實際調用服務端檢查 OBB 的掛載狀態。

## 修復位置
`frameworks/base/core/java/android/os/storage/StorageManager.java`

## 修復方法
恢復對 `mStorageManager.isObbMounted()` 的遠程調用。

## 原始代碼
```java
public boolean isObbMounted(String rawPath) {
    Preconditions.checkNotNull(rawPath, "rawPath cannot be null");
    return false;  // Bug: 直接返回 false
}
```

## 修復後代碼
```java
public boolean isObbMounted(String rawPath) {
    Preconditions.checkNotNull(rawPath, "rawPath cannot be null");
    try {
        return mStorageManager.isObbMounted(rawPath);
    } catch (RemoteException e) {
        throw e.rethrowFromSystemServer();
    }
}
```

## 知識點
1. OBB 是 Android 的擴展文件格式，用於大型遊戲資源
2. `isObbMounted()` 需要與系統服務通信檢查掛載狀態
3. Binder 遠程調用是 Android 服務通信的核心機制

## 調試技巧
1. 確認 OBB 掛載回調已正確觸發
2. 檢查 `isObbMounted()` 的實現邏輯
3. 驗證與 StorageManagerService 的通信
