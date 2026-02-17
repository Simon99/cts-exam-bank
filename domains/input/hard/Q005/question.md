# Q005: KeyEvent dispatch() 組合鍵狀態不一致

## CTS Test
`android.view.cts.AppKeyCombinationsTest#testModifierKeyDispatch`

## Failure Log
```
junit.framework.AssertionFailedError: Modifier key state inconsistent during dispatch
Key sequence: CTRL down -> A down -> A up -> CTRL up

At 'A down' event:
  event.isCtrlPressed() = true
  event.getMetaState() & META_CTRL_ON = 0  // Should be non-zero!

Expected: Both methods report CTRL is pressed
Actual: isCtrlPressed() returns true but getMetaState() missing CTRL flag

at android.view.cts.AppKeyCombinationsTest.testModifierKeyDispatch(AppKeyCombinationsTest.java:156)
```

## 現象描述
CTS 測試發現在組合鍵按下過程中，`isCtrlPressed()` 和 `getMetaState()` 返回不一致的結果。
`isCtrlPressed()` 正確報告 CTRL 已按下，但 `getMetaState()` 中缺少 `META_CTRL_ON` 標誌。

## 提示
- `isCtrlPressed()` 和 `getMetaState()` 應該返回一致的資訊
- `META_CTRL_ON` 和 `META_CTRL_LEFT_ON/META_CTRL_RIGHT_ON` 是不同的常數
- 組合鍵狀態在事件傳遞過程中應該保持不變

## 選項

A) `dispatch()` 更新了內部狀態但未同步更新 metaState 欄位

B) `isCtrlPressed()` 檢查 `META_CTRL_LEFT_ON | META_CTRL_RIGHT_ON`，但 metaState 只設定了其中一個

C) `dispatch()` 中 metaState 使用 `=` 賦值而非 `|=`，覆蓋了之前的修飾鍵狀態

D) `normalizeMetaState()` 未將 `META_CTRL_LEFT_ON` 轉換為 `META_CTRL_ON`
