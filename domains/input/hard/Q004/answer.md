# Q004 Answer

## 正確答案：A

## 解析

### 問題根因
`split()` 方法在遍歷原始事件的指標時，使用了 `break` 語句在找到第一個符合遮罩的指標後就退出迴圈，導致後續符合條件的指標被遺漏。

### Bug 程式碼邏輯
```java
for (int i = 0; i < pointerCount; i++) {
    int id = getPointerId(i);
    if ((pointerIdBits & (1 << id)) != 0) {
        // Copy pointer data to new event
        newEvent.addPointer(coords[i]);
        break;  // BUG: Should continue to check other pointers
    }
}
```

### 正確邏輯
應該繼續遍歷所有指標：
```java
for (int i = 0; i < pointerCount; i++) {
    int id = getPointerId(i);
    if ((pointerIdBits & (1 << id)) != 0) {
        newEvent.addPointer(coords[i]);
        // No break - continue checking
    }
}
```

### 為什麼其他選項不對

**B) 使用 `==` 比較遮罩**
- 如果是 `==` 比較，那麼只有當 pointerIdBits 完全等於 `(1 << id)` 時才會匹配
- 這會導致只能選中單一指標的情況，但題目顯示確實選中了第一個符合的指標 (id=0)
- 這說明位元運算本身是正確的

**C) pointerIndex 未正確遞增**
- 如果是這個問題，會導致指標座標覆蓋，但總數仍應該是 2
- 實際結果是 count=1，說明根本沒有加入第二個指標

**D) 只檢查連續的 ID**
- 遮罩是 0b101，對應 ID 0 和 2
- 如果只檢查連續 ID，應該會得到 ID 0 和 1，但結果只有 ID 0
- 這不符合觀察到的行為

### 關鍵洞察
多點觸控分裂是 Android 視圖系統的核心功能，用於將觸控事件正確分發到不同的子視圖。這個 bug 會導致觸控事件在視圖層級傳遞時丟失部分指標資訊。
