# H-Q003: Display Event 回調缺失

## 問題描述

你收到一份 CTS 測試報告，顯示 Display 事件監聽測試失敗：

```
FAILURE: android.display.cts.DisplayEventTest#testDisplayEvents
java.lang.AssertionError: Display event callback not received
Expected callback count: >= 1
Actual callback count: 0

=============== Summary ===============
PASSED            : 92
FAILED            : 4
```

註冊了 `DisplayManager.DisplayListener` 後，display 發生變化但回調沒有被觸發。

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -t android.display.cts.DisplayEventTest#testDisplayEvents -s <device_serial>
```

## 任務

1. 追蹤 display 事件從產生到派發的完整路徑
2. 找出事件在哪裡被遺漏
3. 提供修復方案

## 提示

- 事件產生和事件派發是不同的階段
- Display 變化有多種類型（DIFF_*）
- 注意事件過濾的 bitmask 邏輯

## 難度

Hard（跨 3+ 個檔案的調用鏈追蹤）

## 時間限制

40 分鐘
