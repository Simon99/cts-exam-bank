# Q004 答案解析

## Bug 位置

`frameworks/base/location/java/android/location/LocationRequest.java` 的 Builder 類

## Bug 描述

Builder 的預設 quality 值設定錯誤。

原始正確代碼（在 Builder 類中）：
```java
private @Quality int mQuality = QUALITY_BALANCED_POWER_ACCURACY;
```

Bug 代碼：
```java
private @Quality int mQuality = QUALITY_HIGH_ACCURACY;
```

## 修復方式

將 Builder 中的 `mQuality` 預設值從 `QUALITY_HIGH_ACCURACY` 改回 `QUALITY_BALANCED_POWER_ACCURACY`。

## 調試思路

1. 測試期望預設 quality 為 QUALITY_BALANCED_POWER_ACCURACY (102)
2. 實際返回 QUALITY_HIGH_ACCURACY (100)
3. 查看 LocationRequest.Builder 類的建構子和欄位初始化
4. 找到 mQuality 的預設值設定錯誤

## 涉及檔案

1. `frameworks/base/location/java/android/location/LocationRequest.java`
