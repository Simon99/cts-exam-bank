# CTS 題目：DIS-M002

## 題目資訊
- **難度**: Medium
- **領域**: Display / Brightness
- **預估時間**: 25 分鐘

## 情境描述

你是 Android Framework 團隊的工程師，負責維護 Display 子系統。QA 團隊回報 CTS 測試失敗：

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.display.cts.BrightnessTest#testSetGetSimpleCurve
```

測試嘗試設定自訂亮度曲線（brightness curve），然後讀取回來驗證。測試失敗表示設定的曲線沒有正確儲存或回傳。

## 測試說明

`BrightnessTest#testSetGetSimpleCurve` 執行以下步驟：
1. 取得預設亮度配置
2. 建立新的 BrightnessConfiguration（2 點曲線：lux [0, 1000] → nits [20, 500]）
3. 呼叫 `setBrightnessConfiguration(config)`
4. 呼叫 `getBrightnessConfiguration()` 取回設定
5. 驗證回傳的設定與原始設定相同

## 相關程式碼

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**關鍵方法**:
- `setBrightnessConfigurationForDisplayInternal()` - 內部儲存亮度配置的核心邏輯
- `validateBrightnessConfiguration()` - 驗證配置是否有效

## 除錯提示

1. 追蹤 `setBrightnessConfiguration()` 從 Binder 呼叫到內部實作的路徑
2. 檢查 `setBrightnessConfigurationForDisplayInternal()` 中的條件判斷
3. 特別注意可能導致提前返回的條件
4. 思考：什麼樣的條件檢查可能導致有效的配置被忽略？

## 任務

1. 找出導致 CTS 測試失敗的 bug
2. 說明 bug 的根本原因
3. 提供修復方案

## 評分標準

- 正確定位 bug 位置 (30%)
- 理解 bug 成因 (30%)
- 修復方案正確性 (30%)
- 說明清晰度 (10%)
