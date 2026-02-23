# Issue: Q002 (DIS-M002) Bug 未被偵測

## 基本資訊
- **題目 ID**: Q002
- **Domain**: display/medium
- **失敗步驟**: C5 (確認失敗)
- **問題類型**: Bug 未被偵測

## 問題描述

Bug patch 將 `logicalWidth` 和 `logicalHeight` 交叉指派：
```java
out.logicalWidth = source.logicalHeight;  // 錯誤
out.logicalHeight = source.logicalWidth;  // 錯誤
```

但 CTS 測試 `testGetMetrics` 仍然 PASS。

## 可能原因

1. 測試不夠敏感，無法偵測 width/height 交換
2. `DisplayInfoOverrides.WM_OVERRIDE_FIELDS` 的調用路徑在測試中未被觸發
3. 需要選擇不同的 CTS 測試

## 相關檔案
- Patch: `domains/display/medium/Q002/bug.patch`
- Meta: `domains/display/medium/Q002/meta.json`
- CTS 結果: `domains/display/medium/Q002/cts_results/`

## 建議修復方向
1. 分析 `testGetMetrics` 的實際驗證邏輯
2. 尋找會檢查 width/height 對稱性的測試
3. 或修改 bug 注入點到更容易被偵測的位置

## 建立時間
2026-02-18 00:26
