# Issue 0008: DIS-H010 測試被跳過（需 Android TV）

## 基本資訊
- **題目 ID**: DIS-H010 (display/hard/Q010)
- **發現日期**: 2026-02-13
- **嚴重程度**: Medium（測試選錯，需換測試）

## 問題描述

CTS 測試因設備不符而被跳過（ASSUMPTION_FAILED）。

## 錯誤訊息

```
org.junit.AssumptionViolatedException: Need an Android TV device to run this test.
at android.display.cts.DefaultDisplayModeTest.setUp(DefaultDisplayModeTest.java:76)
```

## 問題分析

- 測試 `DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents` 只能在 **Android TV 設備**上運行
- 我們的測試設備是 Pixel 7（手機），不是 TV
- 題目的 CTS 測試選擇不當

## Bug Patch 內容

```java
// 只在設置新 mode 時呼叫 storeModeInGlobalSettingsLocked
// 清除 mode（mode == null）時不呼叫，導致不產生 Display Changed 事件
if (mode != null) {
    storeModeInGlobalSettingsLocked(
            resolutionWidth, resolutionHeight, refreshRate, mode);
}
```

## 建議修復方案

### 方案 A：換不同的 CTS 測試
找一個驗證 `setUserPreferredDisplayMode(null)` 行為的測試，且不限於 TV 設備

### 方案 B：標記為 TV-Only 題目
如果找不到手機可用的測試，將此題標記為「僅適用於 Android TV 設備」

## 相關檔案
- Bug Patch: `domains/display/hard/Q010_bug.patch`
- 修改檔案: `DisplayManagerService.java`

## 狀態
- [ ] 待修復（需找替代測試或標記為 TV-Only）
