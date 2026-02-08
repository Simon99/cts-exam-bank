# H-Q001: Display Mode 偏好設定後讀取失敗

## 問題描述

你收到一份 CTS 測試報告，顯示 Display Mode 偏好設定相關測試失敗：

```
FAILURE: android.display.cts.DefaultDisplayModeTest#testSetUserPreferredDisplayModeForSpecificDisplay
java.lang.AssertionError: User preferred display mode not persisted
Expected: Mode{width=1920, height=1080, refreshRate=60.0}
Actual: null

=============== Summary ===============
PASSED            : 92
FAILED            : 4
```

用 `setUserPreferredDisplayMode()` 設定成功（沒有報錯），但隨後 `getUserPreferredDisplayMode()` 卻返回 null。

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.DefaultDisplayModeTest#testSetUserPreferredDisplayModeForSpecificDisplay -s <device_serial>
```

## 任務

1. 追蹤設定和讀取的完整調用鏈
2. 找出數據在哪裡丟失
3. 提供修復方案

## 提示

- 設定 API 沒有報錯，說明前半段正常
- 偏好設定需要持久化存儲
- 注意數據類型轉換可能造成的精度丟失

## 難度

Hard（跨 3+ 個檔案的調用鏈追蹤）

## 時間限制

40 分鐘
