# Q007 Answer: getMaximumRange Returns Negative Value

## 問題根因
在 `Sensor.java` 的 `getMaximumRange()` 方法中，
返回值時加了負號，導致正值變成負值。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// 錯誤的代碼
public float getMaximumRange() {
    return -mMaxRange;  // BUG: 不應該有負號
}

// 正確的代碼
public float getMaximumRange() {
    return mMaxRange;
}
```

## 相關知識
- 加速度感測器的典型範圍是 ±4g (~39.2 m/s²)
- 感測器範圍表示可測量的最大絕對值
- CDD 要求範圍必須是正數

## 難度說明
**Easy** - 返回值和預期值正好差一個負號，非常容易定位。
