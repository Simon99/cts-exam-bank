# Issue: M006 Bug 未被偵測

**題目**: display/medium/Q006
**日期**: 2026-02-17 23:05
**問題類型**: Bug 未被偵測

## 問題描述

M006 的 bug 是移除 `releaseVirtualDisplayInternal()` 中對 device 的 null 檢查，理論上應該導致 NullPointerException。但 CTS VirtualDisplayTest 的 10 個測試全部 PASS。

## Bug 內容

```diff
- if (device != null) {
-     mDisplayDeviceRepo.onDisplayDeviceEvent(device, DISPLAY_DEVICE_EVENT_REMOVED);
- }
+ mDisplayDeviceRepo.onDisplayDeviceEvent(device, DISPLAY_DEVICE_EVENT_REMOVED);
```

## CTS 結果

```
Total Tests: 10
PASSED: 10
FAILED: 0
```

## 分析

CTS VirtualDisplayTest 測試中：
- 正常創建 VirtualDisplay 後釋放 → device 不為 null → PASS
- 沒有測試「釋放不存在的 VirtualDisplay」這種邊緣情況

## 解決方案

1. **換測試**：找其他會觸發 null device 的測試路徑
2. **改 bug 設計**：修改其他會被現有測試驗證的邏輯

## 相關檔案

- `/home/simon/develop_claw/cts-exam-bank/domains/display/medium/Q006/`
- Patch: `bug.patch`
- Meta: `meta.json`（需更新 cts_test）
