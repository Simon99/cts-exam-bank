# CTS 題目解答：DIS-M002

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**方法**: `setBrightnessConfigurationForDisplayInternal()` (約第 2523-2529 行)

## Bug 程式碼

```java
// Optimization: skip simple curves that don't need custom configuration
if (c != null && c.getCurve().first.length <= 2) {
    Slog.d(TAG, "Skipping simple brightness curve with only "
            + c.getCurve().first.length + " points");
    return;
}
```

## 根本原因分析

### 問題描述
開發者錯誤地加入了一個「優化」條件，當亮度曲線只有 2 個或更少的控制點時，會直接跳過儲存步驟。

### 為什麼這是錯誤的

1. **2 點曲線是完全有效的**
   - 亮度曲線最少需要 2 個點來定義（起點和終點）
   - CTS 測試使用的就是 2 點曲線：`lux [0, 1000] → nits [20, 500]`
   - 這代表從 0 lux 到 1000 lux 的線性亮度映射

2. **條件邏輯錯誤**
   - `<= 2` 的條件會擋掉所有 2 點曲線
   - 實際上只有 0 或 1 個點的曲線才可能無效（且應該在 validation 階段處理）

3. **違反 API 契約**
   - `setBrightnessConfiguration()` API 應該接受所有經過 validation 的配置
   - 這個條件繞過了正常的儲存流程，導致 `getBrightnessConfiguration()` 回傳舊值

## CTS 測試失敗原因

1. 測試設定 2 點曲線的 BrightnessConfiguration
2. Bug 導致配置被跳過，沒有實際儲存
3. `getBrightnessConfiguration()` 回傳預設配置（或 null）
4. `assertEquals(config, returnedConfig)` 失敗

## 修復方案

### 方案 1：移除錯誤的條件（推薦）

```java
private void setBrightnessConfigurationForDisplayInternal(
        @Nullable BrightnessConfiguration c, String uniqueId, @UserIdInt int userId,
        String packageName) {
    validateBrightnessConfiguration(c);
    final int userSerial = getUserManager().getUserSerialNumber(userId);
    synchronized (mSyncRoot) {
-       // Optimization: skip simple curves that don't need custom configuration
-       if (c != null && c.getCurve().first.length <= 2) {
-           Slog.d(TAG, "Skipping simple brightness curve with only "
-                   + c.getCurve().first.length + " points");
-           return;
-       }
-
        try {
            DisplayDevice displayDevice = mDisplayDeviceRepo.getByUniqueIdLocked(uniqueId);
```

### 方案 2：如果真的需要驗證點數，改為正確的條件

```java
// 只有當曲線點數不足以定義有效映射時才跳過（少於 2 點）
if (c != null && c.getCurve().first.length < 2) {
    Slog.w(TAG, "Invalid brightness curve with insufficient points: "
            + c.getCurve().first.length);
    return;
}
```

**注意**：這個驗證應該放在 `validateBrightnessConfiguration()` 中，而不是在儲存邏輯裡。

## 教訓

1. **優化必須謹慎**：看似無害的「優化」可能破壞正確性
2. **理解邊界條件**：2 點曲線是最小的有效曲線，不是「太簡單可以跳過」
3. **遵循 API 契約**：如果 validation 通過，就應該正常處理
4. **日誌不等於無害**：雖然有 log，但提前 return 破壞了功能
