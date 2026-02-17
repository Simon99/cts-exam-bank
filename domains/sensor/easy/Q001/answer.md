# Q001 Answer: Sensor Registration Returns False Unexpectedly

## 問題根因
在 `SensorManager.java` 的 `registerListener()` 方法中，當使用 delay 常數
（如 `SENSOR_DELAY_NORMAL`）時，需要透過 `getDelay()` 方法轉換為實際的微秒數。

Bug 在於 `getDelay()` 方法中，`SENSOR_DELAY_NORMAL` 的判斷條件寫錯，
導致它被當作無效的 delay 值處理，返回 -1，進而使註冊失敗。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
private static int getDelay(int rate) {
    int delay = -1;
    switch (rate) {
        case SENSOR_DELAY_FASTEST:
            delay = 0;
            break;
        case SENSOR_DELAY_GAME:
            delay = 20000;
            break;
        case SENSOR_DELAY_UI:
            delay = 60000;  // BUG: 這裡應該處理 SENSOR_DELAY_NORMAL
            break;
    }
    return delay;
}

// 正確的代碼
private static int getDelay(int rate) {
    int delay = -1;
    switch (rate) {
        case SENSOR_DELAY_FASTEST:
            delay = 0;
            break;
        case SENSOR_DELAY_GAME:
            delay = 20000;
            break;
        case SENSOR_DELAY_UI:
            delay = 60000;
            break;
        case SENSOR_DELAY_NORMAL:
            delay = 200000;
            break;
    }
    return delay;
}
```

## 相關知識
- SENSOR_DELAY_FASTEST = 0 (0 μs)
- SENSOR_DELAY_GAME = 1 (20000 μs = 50 Hz)
- SENSOR_DELAY_UI = 2 (60000 μs ≈ 16 Hz)
- SENSOR_DELAY_NORMAL = 3 (200000 μs = 5 Hz)

## 難度說明
**Easy** - 錯誤訊息明確指出 registerListener 失敗，只需檢查 delay 常數處理邏輯即可。
