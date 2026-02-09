# Q004 提示

## 提示 1（輕微）
問題在於事件傳播鏈中的狀態比較邏輯。思考：要檢測變化，需要比較「變化前」和「變化後」的狀態。

## 提示 2（中等）
查看 `LogicalDisplayMapper.updateLogicalDisplaysLocked()` 方法，特別注意：
- `mTempDisplayInfo.copyFrom()` 保存什麼狀態？
- `display.updateLocked()` 做什麼？
- `display.getDisplayInfoLocked()` 返回什麼？

執行順序對結果有什麼影響？

## 提示 3（強烈）
在第 720 行附近，檢查以下操作的順序：
1. `mTempDisplayInfo.copyFrom(display.getDisplayInfoLocked())` - 應該保存「舊」狀態
2. `display.updateLocked(mDisplayDeviceRepo)` - 更新 display
3. `display.getDisplayInfoLocked()` - 獲取「新」狀態

如果順序錯誤，`mTempDisplayInfo` 和 `newDisplayInfo` 都會是同一個（更新後的）狀態，導致比較結果永遠為「沒有變化」。

## 涉及的檔案
1. `LogicalDisplayMapper.java` - 核心問題所在
2. `LogicalDisplay.java` - updateLocked 和 getDisplayInfoLocked
3. `DisplayManagerService.java` - 事件接收端
4. `VirtualDisplayAdapter.java` - 事件觸發端
