# Issue 0004: DIS-H004 Bug 可能導致系統崩潰

## 基本資訊
- **題目 ID**: DIS-H004 (display/hard/Q004)
- **發現日期**: 2026-02-11
- **嚴重程度**: Critical（預測會崩潰，未實測）

## 問題描述

Bug patch 類似 DIS-H002，會截斷 supportedModes 陣列。基於 H002 的測試結果，預測此 bug 也會導致系統無法正常啟動。

## Bug Patch 內容

```java
// 原始
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
    deviceInfo.supportedModes, deviceInfo.supportedModes.length);

// Bug（永遠截斷一個 mode）
int modesCount = deviceInfo.supportedModes.length;
int effectiveCount = modesCount > 1
    ? Math.min(modesCount - 1, deviceInfo.supportedModes.length)  // 少一個
    : modesCount;
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
    deviceInfo.supportedModes, effectiveCount);
```

## 問題分析

與 H002 相比，此 bug 更嚴重：
- **H002**: 只在 `mDirty=true` 時觸發
- **H004**: 只要 `modesCount > 1` 就永遠觸發

這會在系統啟動時立即生效，導致 Display 子系統初始化失敗。

## 建議修復方案

與 H002 相同：
1. 重新設計 bug，避免影響系統啟動
2. 或讓 bug 只在特定操作時觸發

## 相關檔案
- Bug Patch: `domains/display/hard/Q004_bug.patch`
- 修改檔案: `LogicalDisplay.java`
- 相關 Issue: Issue_0002_DIS_H002_system_crash.md

## 狀態
- [ ] 待修復（建議與 H002 一起處理）
