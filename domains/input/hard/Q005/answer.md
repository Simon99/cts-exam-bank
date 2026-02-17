# Q005 Answer

## 正確答案：D

## 解析

### 問題根因
`normalizeMetaState()` 方法負責將具體的左/右修飾鍵標誌轉換為通用的修飾鍵標誌。例如，當 `META_CTRL_LEFT_ON` 被設定時，也應該設定 `META_CTRL_ON`。但這個轉換邏輯缺失或不完整。

### 狀態定義
```java
// 具體的左/右鍵標誌
META_CTRL_LEFT_ON  = 0x00002000
META_CTRL_RIGHT_ON = 0x00004000

// 通用標誌（應同時設定）
META_CTRL_ON = 0x00001000
```

### isCtrlPressed() 實作
```java
public boolean isCtrlPressed() {
    return (mMetaState & (META_CTRL_LEFT_ON | META_CTRL_RIGHT_ON)) != 0;
}
```
這個方法檢查左或右 CTRL 鍵，所以返回 true。

### getMetaState() 問題
直接返回 `mMetaState`，但 `META_CTRL_ON` 沒有被設定。

### Bug 程式碼
```java
static int normalizeMetaState(int metaState) {
    // BUG: Missing normalization for CTRL
    if ((metaState & (META_SHIFT_LEFT_ON | META_SHIFT_RIGHT_ON)) != 0) {
        metaState |= META_SHIFT_ON;
    }
    if ((metaState & (META_ALT_LEFT_ON | META_ALT_RIGHT_ON)) != 0) {
        metaState |= META_ALT_ON;
    }
    // Missing: CTRL normalization
    return metaState;
}
```

### 為什麼其他選項不對

**A) dispatch() 未同步更新 metaState**
- `isCtrlPressed()` 也是讀取 mMetaState，兩者應該一致
- 問題不在於更新時機，而在於值本身

**B) isCtrlPressed() 檢查 LEFT|RIGHT**
- 這正是為什麼 `isCtrlPressed()` 能正確返回 true
- 但這是正確的實作，不是 bug

**C) 使用 `=` 覆蓋狀態**
- 如果是覆蓋，那之前的修飾鍵也會丟失
- 但問題描述中只有 CTRL 狀態不一致

### 關鍵洞察
Android 的修飾鍵系統有兩層標誌：具體的（左/右）和通用的。應用程式可能使用任一種方式檢查修飾鍵狀態，因此必須保持同步。
