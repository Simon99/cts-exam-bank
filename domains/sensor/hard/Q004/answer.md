# Q004 Answer: getHighestDirectReportRateLevel Returns Unsupported Rate

## 問題根因
在 `Sensor.java` 的 `getHighestDirectReportRateLevel()` 方法中，
從 flags 解析最高支援的 rate level 時，位移量計算錯誤。
導致讀取到錯誤的位元，返回了不支援的 rate level。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// flags 結構（假設）:
// bit 10-11: memory file support
// bit 12-13: hardware buffer support  
// bit 14-16: highest rate level (0-4)
private static final int DIRECT_REPORT_RATE_SHIFT = 14;
private static final int DIRECT_REPORT_RATE_MASK = 0x7 << DIRECT_REPORT_RATE_SHIFT;

// 錯誤的代碼（位移錯誤）
public int getHighestDirectReportRateLevel() {
    // BUG: 使用了錯誤的位移量
    return (mFlags >> 12) & 0x7;  // 取到了 hardware buffer 的位元
}

// 正確的代碼
public int getHighestDirectReportRateLevel() {
    return (mFlags & DIRECT_REPORT_RATE_MASK) >> DIRECT_REPORT_RATE_SHIFT;
}
```

## 相關知識
- RATE_STOP = 0, RATE_NORMAL = 1, RATE_FAST = 2, RATE_VERY_FAST = 3
- Direct report rate 決定感測器寫入 shared memory 的頻率
- CTS 會驗證 getHighestDirectReportRateLevel 與 configure 的一致性

## 難度說明
**Hard** - 需要理解複雜的 flags 位元結構和位元操作。
