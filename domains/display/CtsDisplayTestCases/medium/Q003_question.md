# M-Q003: HDR Capabilities 返回錯誤

## 問題描述

你收到一份 CTS 測試報告，顯示 `CtsDisplayTestCases` 有 2 個測試失敗：

```
=============== Summary ===============
2/2 modules completed
PASSED            : 94
FAILED            : 2
```

失敗的測試是 `testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes`：

```
FAILURE: arrays first differed at element [0]; expected:<2> but was:<1>
```

根據測試名稱和錯誤訊息：
- 測試設定了某些 HDR 格式為 disabled
- 期望 `getHdrCapabilities()` 返回過濾後的結果
- 但返回的 HDR type 陣列不對

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -s <device_serial>
```

## 任務

1. 分析 HDR capabilities 過濾機制
2. 找出為什麼返回的陣列元素不對
3. 提供修復方案

## 提示

- `userDisabledHdrTypes` 是用戶禁用的 HDR 格式列表
- `getHdrCapabilities()` 應該返回**啟用**的格式
- expected:<2> = HDR_TYPE_HDR10, was:<1> = HDR_TYPE_DOLBY_VISION

## 難度

Medium（需要追踪過濾邏輯，理解 contains() 的用法）

## 時間限制

25 分鐘
