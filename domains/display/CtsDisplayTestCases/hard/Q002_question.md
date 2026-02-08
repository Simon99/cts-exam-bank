# H-Q002: 自動亮度配置切換用戶後丟失

## 問題描述

你收到一份 CTS 測試報告，顯示多用戶場景下亮度配置測試失敗：

```
FAILURE: android.display.cts.BrightnessTest#testSetAndGetPerDisplay
java.lang.AssertionError: Brightness configuration lost after user switch
Expected: BrightnessConfiguration{curve=[...]}
Actual: null

=============== Summary ===============
PASSED            : 92
FAILED            : 4
```

在多用戶環境下：
1. 用戶 A 設定了 brightness configuration
2. 切換到用戶 B
3. 切回用戶 A
4. 用戶 A 的 brightness configuration 丟失了

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.BrightnessTest#testSetAndGetPerDisplay -s <device_serial>
```

## 任務

1. 追蹤用戶切換時的配置載入邏輯
2. 找出配置在哪裡被錯誤清除
3. 提供修復方案

## 提示

- 用戶切換時會觸發配置重載
- 每個用戶應該有獨立的配置
- 注意配置清理的範圍（per-user vs global）

## 難度

Hard（跨 3+ 個檔案的調用鏈追蹤）

## 時間限制

40 分鐘
