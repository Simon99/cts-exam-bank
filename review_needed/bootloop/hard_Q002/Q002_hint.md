# Q002 提示

## 提示 1（方向性）
Bug 不在數據源頭（DisplayDeviceInfo），也不在中間層（LogicalDisplay）。系統內部數據是完整的，問題出在數據最終暴露給應用的地方。

## 提示 2（具體位置）
檢查 `Display.java` 中的 `getSupportedModes()` 方法。特別注意 `Arrays.copyOf()` 的參數。

## 提示 3（Bug 類型）
這是一個 off-by-one 錯誤，發生在防禦性複製時。正確應該複製整個陣列，但程式碼複製了 `length - 1` 個元素。
