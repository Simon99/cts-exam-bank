# M-Q001: Display CTS Process Crashed

## 問題描述

你收到一份 CTS 測試報告，顯示 `CtsDisplayTestCases` 全部測試都因為 "Process crashed" 而失敗：

```
=============== Summary ===============
    arm64-v8a CtsDisplayTestCases[instant]: Instrumentation run failed due to 'Process crashed.'
    arm64-v8a CtsDisplayTestCases: Instrumentation run failed due to 'Process crashed.'
PASSED            : 0
FAILED            : 6
```

測試 log 顯示最後執行的測試是 `DisplayEventTest#testDisplayEvents`，之後測試程序就崩潰了。

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -s <device_serial>
```

## 任務

1. 分析可能導致所有 Display 相關測試崩潰的原因
2. 找出 bug 的位置
3. 提供修復方案

## 提示

- 這類全面崩潰通常發生在測試初始化階段
- Display 相關的數據需要跨進程傳輸
- 注意 Parcel 序列化/反序列化的順序

## 難度

Medium（跨檔案追蹤，需理解 Parcel 機制）

## 時間限制

30 分鐘
