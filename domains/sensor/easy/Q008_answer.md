# Q008 Answer: getResolution Returns Zero

## 問題根因
在 `Sensor.java` 的建構函數中，
`mResolution` 欄位未被正確賦值。參數 `resolution` 被忽略，
導致欄位保持預設值 0.0。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// 錯誤的代碼（缺少賦值）
Sensor(..., float resolution, ...) {
    mMaxRange = maxRange;
    // mResolution = resolution;  // 這行被漏掉了
    mPower = power;
}

// 正確的代碼
Sensor(..., float resolution, ...) {
    mMaxRange = maxRange;
    mResolution = resolution;
    mPower = power;
}
```

## 相關知識
- 解析度表示感測器可偵測的最小變化量
- 通常以感測器單位表示（如 m/s² for accelerometer）
- float 欄位的預設值是 0.0f

## 難度說明
**Easy** - 返回值是 0，明顯是欄位未初始化，檢查建構函數即可。
