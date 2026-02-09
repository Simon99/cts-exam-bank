# Q006 提示

## 提示 1
搜尋 `VIRTUAL_DISPLAY_FLAG_PRESENTATION` 的處理邏輯

## 提示 2
檢查 VirtualDisplayAdapter 中設置 flags 的代碼段

## 提示 3
比較 `|=`（OR 賦值）和 `&=`（AND 賦值）的效果：
- `flags |= FLAG_X` → 添加 flag
- `flags &= FLAG_X` → 保留 flag（如果 flags 中原本沒有這個 flag，結果會清除）

## 答案方向
`&=` 被錯誤使用，應該用 `|=` 來添加 flag
