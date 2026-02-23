# Issue: DIS-M006 - Bug 未被偵測

## 基本資訊
- **題目 ID:** Q006
- **題目標題:** Virtual Display 釋放時的空指標處理缺陷
- **失敗步驟:** C5
- **問題類型:** Bug 未被偵測

## 問題描述

CTS 測試 `android.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay` 執行 **PASSED**，
表示 bug.patch 埋的 bug 沒有被測試偵測到。

## Bug 設計
- **Patch 內容:** 移除了 `releaseVirtualDisplayInternal()` 中對 device 的 null 檢查
- **預期影響:** 當虛擬顯示器不存在或已被釋放時，將 null 傳給 `onDisplayDeviceEvent()` 造成 NullPointerException
- **實際結果:** 測試正常通過

## 分析

`testPrivateVirtualDisplay` 測試流程：
1. 創建私有虛擬顯示器
2. 驗證顯示器功能
3. 正常釋放顯示器

Bug 觸發條件：釋放**不存在**的虛擬顯示器
但測試只釋放**已創建且存在**的顯示器，不會觸發 null pointer 場景。

## 建議修復方向

1. **方案 A:** 尋找會測試重複釋放或釋放不存在顯示器的測試
2. **方案 B:** 重新設計 bug，改變會影響正常創建/使用/釋放流程的邏輯
3. **方案 C:** 修改 bug 位置，例如影響 createVirtualDisplay 的返回值

## 相關檔案
- `domains/display/medium/Q006/bug.patch`
- `domains/display/medium/Q006/meta.json`

## 驗證資訊
- **驗證日期:** 2026-02-17
- **設備:** 27161FDH20031X
- **CTS 結果:** PASSED
