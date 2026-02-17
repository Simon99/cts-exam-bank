# Q007 Answer: getReportingMode Returns Incorrect Mode

## 問題根因
在 `Sensor.java` 的 `getReportingMode()` 方法中，
位元遮罩和位移量錯誤。Reporting mode 儲存在 flags 的 bit 1-2，
但 bug 使用了錯誤的遮罩，導致取出的值總是 0。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// flags 結構: bit 0 = wake-up, bit 1-2 = reporting mode
private static final int REPORTING_MODE_MASK = 0x6;  // 正確: 0b110
private static final int REPORTING_MODE_SHIFT = 1;

// 錯誤的代碼
public int getReportingMode() {
    return mFlags & 0x1;  // BUG: 遮罩錯誤，只取 bit 0
}

// 正確的代碼
public int getReportingMode() {
    return (mFlags & REPORTING_MODE_MASK) >> REPORTING_MODE_SHIFT;
}
```

## 相關知識
- REPORTING_MODE_CONTINUOUS = 0（連續報告）
- REPORTING_MODE_ON_CHANGE = 1（變化時報告）
- REPORTING_MODE_ONE_SHOT = 2（一次性）
- REPORTING_MODE_SPECIAL_TRIGGER = 3（特殊觸發）

## 難度說明
**Medium** - 需要理解 flags 的位元結構和遮罩操作。
