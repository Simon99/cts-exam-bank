# Q004 提示

## 提示 1（輕微）
問題在於事件傳播鏈中的條件判斷邏輯。思考：什麼情況下應該發送 DISPLAY_CHANGED 事件？

## 提示 2（中等）
查看 `LogicalDisplayMapper.updateLogicalDisplaysLocked()` 方法，在第 781 行附近：
```java
} else if (wasDirty ??? !mTempDisplayInfo.equals(newDisplayInfo)) {
```

思考：
- 這個條件應該使用 `||`（OR）還是 `&&`（AND）？
- 用自然語言描述：「如果 dirty **或** info 改變」vs「如果 dirty **且** info 改變」

## 提示 3（強烈）
分析 `wasDirty` 在 resize 操作時的值：

1. `mDirty` 在 LogicalDisplay 構造時設為 `true`
2. 第一次 `updateLocked()` 完成後設為 `false`
3. VirtualDisplay.resize() **不會**重新設置 `mDirty = true`
4. 因此在 resize 時：`wasDirty = false`

如果條件是 `wasDirty && !equal`：
- `false && true = false` → 不發送事件 ❌

如果條件是 `wasDirty || !equal`：
- `false || true = true` → 發送事件 ✓

## 涉及的檔案
1. `LogicalDisplayMapper.java` - 核心問題所在（第 778-790 行）
2. `LogicalDisplay.java` - mDirty 的定義和管理
3. `DisplayManagerService.java` - 事件接收端
4. `VirtualDisplayAdapter.java` - 事件觸發端
