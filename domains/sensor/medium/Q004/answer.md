# Q004 Answer: getMinDelay Returns Wrong Value

## 問題根因
在 `Sensor.java` 的 `getMinDelay()` 方法中，
將已經是微秒的值又乘以 1000，導致值變大 1000 倍。

HAL 傳入的 minDelay 已經是微秒單位，不需要轉換。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// 錯誤的代碼
public int getMinDelay() {
    return mMinDelay * 1000;  // BUG: 不需要乘 1000
}

// 正確的代碼
public int getMinDelay() {
    return mMinDelay;
}
```

## 相關知識
- minDelay 表示感測器最快的採樣間隔（微秒）
- 500 Hz 對應 minDelay = 2000 μs
- HAL 傳入的值已經是微秒，API 也返回微秒

## 難度說明
**Medium** - 需要理解單位並追蹤數值的轉換過程。
