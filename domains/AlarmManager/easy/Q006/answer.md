# Q006 Answer: AlarmClockInfo getTriggerTime Returns 0

## 正確答案
**B. `getTriggerTime()` 錯誤地返回了 0 而非 mTriggerTime 欄位**

## 問題根因
在 `AlarmManager.java` 的內部類別 `AlarmClockInfo` 中，
`getTriggerTime()` 方法應該返回 `mTriggerTime` 成員變數，
但 bug 將返回值寫成了 `0`，導致總是返回零時間戳。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (AlarmClockInfo 類別)

## 修復方式
```java
// 錯誤的代碼
public long getTriggerTime() {
    return 0;  // BUG: 應該返回 mTriggerTime
}

// 正確的代碼
public long getTriggerTime() {
    return mTriggerTime;
}
```

## 相關知識
- `AlarmClockInfo` 用於存儲鬧鐘時鐘資訊（時間 + 顯示 Intent）
- 此物件通過 `setAlarmClock()` 設定，用於 UI 顯示
- 實作 Parcelable 介面用於進程間傳遞

## 難度說明
**Easy** - 從 fail log 可以直接看出返回值為 0，只需檢查 getter 實作即可發現問題。
