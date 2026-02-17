# Q004 Answer: App Standby Bucket Delay Calculation Overflow

## 正確答案
**A. 延遲計算使用 int 而非 long，導致大數值溢位變負數**

## 問題根因
在 `AlarmManagerService.java` 的 `adjustDeliveryTimeBasedOnBucketLocked()` 方法中，
計算延遲時間時使用了 `int` 類型。RARE bucket 的延遲可能是數小時（毫秒值很大），
超過 int 最大值 (~21 億) 後溢位變成負數。負數延遲被解釋為「不需要延遲」，
導致鬧鐘立即觸發。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
long adjustDeliveryTimeBasedOnBucketLocked(Alarm alarm) {
    int delayMs = calculateBucketDelay(alarm.standbyBucket);  // BUG: int 溢位
    if (delayMs > 0) {
        return alarm.whenElapsed + delayMs;
    }
    return alarm.whenElapsed;
}

// 正確的代碼
long adjustDeliveryTimeBasedOnBucketLocked(Alarm alarm) {
    long delayMs = calculateBucketDelay(alarm.standbyBucket);  // 用 long
    if (delayMs > 0) {
        return alarm.whenElapsed + delayMs;
    }
    return alarm.whenElapsed;
}
```

## 相關知識
- App Standby Bucket: ACTIVE, WORKING_SET, FREQUENT, RARE, RESTRICTED
- RARE bucket 的鬧鐘延遲可達數小時
- 時間計算應該總是使用 long 以避免溢位

## 難度說明
**Hard** - 整數溢位問題不易發現，只在特定 bucket 和延遲時間組合下發生。
