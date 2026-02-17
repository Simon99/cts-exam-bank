# Q001 Answer: Repeating Alarm Interval Too Short

## 正確答案
**B. `setRepeating()` 傳遞給 setImpl 時沒有使用 `Math.max(interval, INTERVAL_MINIMUM)`**

## 問題根因
在 `AlarmManager.java` 的 `setRepeating()` 方法中，
應該在傳遞 interval 給 `setImpl()` 前，確保 interval 不低於系統最小值。
bug 直接將傳入的 interval 轉發，沒有經過 `Math.max()` 處理，
允許過短的 interval 被設定，可能導致電池快速消耗。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 567-569)

## 修復方式
```java
// 錯誤的代碼
public void setRepeating(int type, long triggerAtMillis, long intervalMillis,
        PendingIntent operation) {
    setImpl(type, triggerAtMillis, WINDOW_EXACT, intervalMillis, 0,  // BUG: 直接使用 intervalMillis
            operation, null, null, (Handler) null, null, null);
}

// 正確的代碼
public void setRepeating(int type, long triggerAtMillis, long intervalMillis,
        PendingIntent operation) {
    setImpl(type, triggerAtMillis, WINDOW_EXACT, 
            Math.max(intervalMillis, INTERVAL_MINIMUM), 0,
            operation, null, null, (Handler) null, null, null);
}
```

## 相關知識
- `INTERVAL_MINIMUM` 定義重複鬧鐘的最小間隔（通常 60 秒）
- 過短的重複間隔會顯著影響電池壽命
- 此限制在 API 19 (KITKAT) 引入

## 難度說明
**Medium** - 需要理解 interval 邊界處理的必要性，以及追蹤參數傳遞路徑。
