# Q006 Answer

## 正確答案：A

## 解析

### 問題根源

在 `InputEventConsistencyVerifier.onTouchEvent()` 中處理 `ACTION_POINTER_DOWN` 時，
更新 pointer 追蹤 bitmap 使用了錯誤的運算符：

```java
// 錯誤寫法
mTouchEventStreamPointers = idBit;  // 覆蓋整個 bitmap

// 正確寫法
mTouchEventStreamPointers |= idBit;  // 將新 bit 加入現有 bitmap
```

### 為什麼導致這個錯誤

`mTouchEventStreamPointers` 是一個 int bitmap，用於追蹤目前按下的所有 pointer：
- 每個 pointer id 對應一個 bit 位置
- `1 << id` 計算該 pointer 的 bit mask
- 多個 pointer 應該使用 `|=` 累加到 bitmap 中

使用 `=` 時，每次新 pointer 按下都會覆蓋整個 bitmap，只保留最新的 pointer。

### 事件流程分析

```
時間線                   正確 bitmap    錯誤 bitmap
ACTION_DOWN (id=0)      0b00000001     0b00000001
ACTION_POINTER_DOWN     0b00000011     0b00000010  ← 第一隻手指丟失！
  (id=1)
ACTION_MOVE (2 ptrs)    檢查通過       檢查失敗
                                       "2 pointers but 1 down"
```

### 為什麼其他選項錯誤

**B) ACTION_DOWN 忘記初始化**
- 實際上 ACTION_DOWN 正確使用 `mTouchEventStreamPointers = 1 << event.getPointerId(0)`
- 在單一 gesture 開始時重置是正確的

**C) 使用 `1 >> id` 而非 `1 << id`**
- 這會導致 bit 往右移（除法效果）而非左移
- 但錯誤日誌顯示 pointer 1 的 bit 正確（0b00000010），所以位移方向沒問題

**D) ACTION_POINTER_UP 使用 `|=` 而非 `&= ~`**
- 這會導致 pointer 無法正確移除
- 但錯誤發生在 ACTION_MOVE 之前，還沒到 UP 事件

### 修復方式

```java
// InputEventConsistencyVerifier.java
} else {
    mTouchEventStreamPointers |= idBit;  // 使用 |= 加入新 bit
}
```

### 相關知識

- **Bitmap 操作**：`|=` 設置 bit，`&= ~` 清除 bit，`&` 檢查 bit
- **多點觸控狀態機**：需要追蹤所有活躍的 pointer
- **InputEventConsistencyVerifier**：用於調試時檢查事件流的一致性
