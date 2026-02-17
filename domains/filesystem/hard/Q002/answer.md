# Q002 答案：VolumeInfo 狀態映射鏈錯誤

## Bug 位置

### Bug 1: VolumeInfo.java - 狀態映射錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 129 行
**問題:** `STATE_FORMATTING` 映射到 `MEDIA_MOUNTED` 而非 `MEDIA_UNMOUNTED`

### Bug 2: StorageManagerService.java - 模擬卷狀態強制錯誤
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 1813-1815 行
**問題:** 強制將模擬卷狀態設為 `UNMOUNTED`

### Bug 3: Environment.java - 常量值錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/Environment.java`
**行號:** 約 128 行
**問題:** `MEDIA_MOUNTED_READ_ONLY` 值與 `MEDIA_MOUNTED` 相同

## 修復方法

### 修復 Bug 1 (VolumeInfo.java):
```java
sStateToEnvironment.put(VolumeInfo.STATE_FORMATTING, Environment.MEDIA_UNMOUNTED);
```

### 修復 Bug 2 (StorageManagerService.java):
```java
if (newState != VolumeInfo.STATE_MOUNTED) {
    vol.state = VolumeInfo.STATE_MOUNTED;
}
```

### 修復 Bug 3 (Environment.java):
```java
public static final String MEDIA_MOUNTED_READ_ONLY = "mounted_ro";
```

## 根本原因分析

這是一個**狀態映射鏈**錯誤：

1. **Environment** 層：常量定義錯誤，無法區分只讀和讀寫掛載
2. **VolumeInfo** 層：格式化狀態映射錯誤
3. **Service** 層：模擬卷（主存儲）永遠顯示為未掛載

錯誤連鎖效應：
- 主存儲報告為未掛載
- 格式化中的卷報告為已掛載
- 只讀掛載和讀寫掛載無法區分

## 調試思路

1. CTS 測試獲取存儲卷狀態
2. 主存儲返回 "unmounted"
3. 追蹤 VolumeInfo.getState() 發現正確
4. 檢查 Service 層的狀態處理，發現強制修改
5. 修復後發現只讀狀態仍有問題，檢查常量定義
6. 修復後格式化狀態仍錯誤，檢查映射表
