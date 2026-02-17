# Q009 答案：VolumeInfo 狀態轉換與廣播映射錯誤

## Bug 位置

### Bug 1: VolumeInfo.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 128 行
**問題:** `STATE_MOUNTED_READ_ONLY` 映射到 `MEDIA_MOUNTED` 而非 `MEDIA_MOUNTED_READ_ONLY`

### Bug 2: StorageManagerService.java
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 1783 行
**問題:** 廣播使用 `oldState` 而非 `newState` 來決定

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
sStateToEnvironment.put(VolumeInfo.STATE_MOUNTED_READ_ONLY, Environment.MEDIA_MOUNTED);

// 正確代碼
sStateToEnvironment.put(VolumeInfo.STATE_MOUNTED_READ_ONLY, Environment.MEDIA_MOUNTED_READ_ONLY);
```

### 修復 Bug 2:
```java
// 錯誤代碼
final String broadcast = VolumeInfo.getBroadcastForEnvironment(
    VolumeInfo.getEnvironmentForState(oldState));

// 正確代碼
final String broadcast = VolumeInfo.getBroadcastForEnvironment(envState);
```

## 根本原因分析

這是一個 **狀態映射 + 廣播選擇** 雙重錯誤：

1. 只讀掛載狀態映射到錯誤的環境常量
2. 廣播基於舊狀態而非新狀態發送

測試場景：
- 卷從 unmounted 變為 mounted_read_only
- 映射返回 MEDIA_MOUNTED（錯誤）
- 廣播基於 oldState=unmounted 發送 UNMOUNTED 廣播

## 調試思路

1. CTS 測試監聽卷狀態變化廣播
2. 收到錯誤的廣播類型
3. 追蹤 `getEnvironmentForState()` 映射
4. 發現只讀狀態映射錯誤
5. 檢查廣播發送邏輯，發現使用錯誤狀態
