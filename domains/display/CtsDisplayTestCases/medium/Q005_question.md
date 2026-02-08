# M-Q005: VirtualDisplay HDR 能力異常

## 問題描述

你收到一份 CTS 測試報告，顯示 `CtsDisplayTestCases` 中 VirtualDisplay 的 HDR 測試失敗：

```
FAILURE: android.display.cts.VirtualDisplayTest#testHdrApiMethods
java.lang.AssertionError: HDR capabilities inconsistent
Expected: HdrCapabilities with supportedHdrTypes=[] and maxLuminance=0.0
Actual: HdrCapabilities with supportedHdrTypes=[] and maxLuminance=500.0

=============== Summary ===============
PASSED            : 94
FAILED            : 2
```

VirtualDisplay 的 HDR capabilities 數據不一致：supportedHdrTypes 為空，但 maxLuminance 卻有值。

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.VirtualDisplayTest#testHdrApiMethods -s <device_serial>
```

## 任務

1. 分析 VirtualDisplay 的 HDR capabilities 為什麼會不一致
2. 找出 bug 的位置
3. 提供修復方案

## 提示

- VirtualDisplay 和實體 Display 的建立路徑不同
- HDR capabilities 包含多個欄位，需要保持一致性
- 追蹤 VirtualDisplay 的初始化流程

## 難度

Medium（需要理解 VirtualDisplay 建立流程，在 Adapter 層加 log）

## 時間限制

25 分鐘
