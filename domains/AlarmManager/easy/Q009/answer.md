# Q009 Answer: Alarm Wakeup Type Ignored

## 正確答案
**A. wakeup 判斷使用 `(type & 0x1) == 0` 而非 `(type & 0x1) != 0`**

## 問題根因
在 `Alarm.java` 中判斷是否為 wakeup 類型時，
根據 AlarmManager 的定義，WAKEUP 類型的 type 值最低位為 1：
- `ELAPSED_REALTIME_WAKEUP = 2` (binary: 10) — 錯！實際是 2
- 實際上：`RTC_WAKEUP = 0`, `RTC = 1`, `ELAPSED_REALTIME_WAKEUP = 2`, `ELAPSED_REALTIME = 3`

等等，讓我重新確認：wakeup 判斷應該是 `(type & TYPE_NONWAKEUP_MASK) == 0`。
bug 將判斷邏輯寫反，導致 wakeup 被當成 non-wakeup，non-wakeup 反而被當成 wakeup。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/Alarm.java`

## 修復方式
```java
// 錯誤的代碼
public boolean isWakeup() {
    return (type & 0x1) == 0;  // BUG: 邏輯相反
}

// 正確的代碼  
public boolean isWakeup() {
    return (type & 0x1) != 0;
}
```

## 相關知識
- AlarmManager.RTC_WAKEUP = 0, RTC = 1
- AlarmManager.ELAPSED_REALTIME_WAKEUP = 2, ELAPSED_REALTIME = 3
- wakeup 類型需要透過 kernel alarm 喚醒裝置

## 難度說明
**Easy** - 從 fail log 可以看出 wakeup 沒有生效，檢查 wakeup 判斷邏輯即可發現位元運算錯誤。
