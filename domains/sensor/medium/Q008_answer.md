# Q008 Answer: getFifoMaxEventCount Returns Reserved Count

## 問題根因
在 `Sensor.java` 的建構函數中，
`mFifoMaxEventCount` 和 `mFifoReservedEventCount` 的賦值被交換了。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// 錯誤的代碼（欄位交換）
Sensor(..., int fifoReservedEventCount, int fifoMaxEventCount, ...) {
    // ...
    mFifoReservedEventCount = fifoMaxEventCount;  // BUG: 應該用 fifoReservedEventCount
    mFifoMaxEventCount = fifoReservedEventCount;  // BUG: 應該用 fifoMaxEventCount
}

// 正確的代碼
Sensor(..., int fifoReservedEventCount, int fifoMaxEventCount, ...) {
    // ...
    mFifoReservedEventCount = fifoReservedEventCount;
    mFifoMaxEventCount = fifoMaxEventCount;
}
```

## 相關知識
- FIFO 用於批次處理感測器事件
- FifoReservedEventCount：此感測器保證可用的 FIFO 空間
- FifoMaxEventCount：FIFO 共享時最多可用的空間
- CDD 要求 max >= reserved

## 難度說明
**Medium** - 需要理解 FIFO 參數的語義並檢查賦值順序。
