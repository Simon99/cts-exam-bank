# H-Q004: Color Mode 設定無效

## 問題描述

你收到一份 CTS 測試報告，顯示 wide color gamut 相關測試失敗：

```
FAILURE: android.display.cts.DisplayTest#testGetSupportWideColorGamut_displayIsWideColorGamut
java.lang.AssertionError: Wide color gamut not enabled
isWideColorGamut() returned true but getSupportedWideColorGamuts() is empty

=============== Summary ===============
PASSED            : 92
FAILED            : 4
```

Display 報告支持 wide color gamut（`isWideColorGamut()` 返回 true），但 `getSupportedWideColorGamuts()` 卻返回空陣列。

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.DisplayTest#testGetSupportWideColorGamut_displayIsWideColorGamut -s <device_serial>
```

## 任務

1. 追蹤 color mode 從設定到查詢的完整路徑
2. 找出數據在哪裡被錯誤處理
3. 提供修復方案

## 提示

- 上層 API 和底層 HAL 之間有映射關係
- 注意常數值的對應是否正確
- Color mode 涉及多層轉換

## 難度

Hard（跨 3+ 個檔案的調用鏈追蹤）

## 時間限制

40 分鐘
