# H-Q005: Overlay Display 的 Metrics 計算錯誤

## 問題描述

你收到一份 CTS 測試報告，顯示 secondary display 的 metrics 測試失敗：

```
FAILURE: android.display.cts.DisplayTest#testGetMetrics
java.lang.AssertionError: Display metrics incorrect for overlay display
Expected density: 320
Actual density: 160

=============== Summary ===============
PASSED            : 92
FAILED            : 4
```

Overlay display 的 density 計算結果只有預期的一半。

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.DisplayTest#testGetMetrics -s <device_serial>
```

## 任務

1. 追蹤 overlay display 的 metrics 計算路徑
2. 找出 density 計算錯誤的原因
3. 提供修復方案

## 提示

- Overlay display 和實體 display 的 metrics 計算不同
- 注意整數除法和浮點數除法的差異
- 運算順序會影響精度

## 難度

Hard（跨 3+ 個檔案的調用鏈追蹤）

## 時間限制

40 分鐘
