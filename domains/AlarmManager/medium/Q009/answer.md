# Q009 Answer: Non-Wakeup Delay Check Wrong

## 正確答案
**C. `checkAllowNonWakeupDelayLocked()` 返回值的語意與呼叫方期望相反**

## 問題根因
在 `AlarmManagerService.java` 的 `checkAllowNonWakeupDelayLocked()` 方法中，
返回 `true` 應該表示「允許延遲」（即應該延遲），
但呼叫此方法的地方期望 `true` 表示「不需要延遲」（立即觸發）。
這導致語意完全相反：應該延遲的情況反而立即觸發。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼 - 呼叫方
if (checkAllowNonWakeupDelayLocked()) {  // BUG: 應該是 !
    deliverAlarm(alarm);
}

// 或者修正方法本身
boolean checkAllowNonWakeupDelayLocked() {
    // BUG: 返回值語意需要反轉
    return mInteractive;  // 應該是 !mInteractive
}

// 正確的代碼
boolean checkAllowNonWakeupDelayLocked() {
    return !mInteractive;  // true = 應該延遲
}
```

## 相關知識
- 非 wakeup 鬧鐘不會喚醒裝置，螢幕關閉時延遲可節省電力
- `mInteractive` 為 true 表示螢幕亮著
- 方法命名和返回值語意需要一致以避免混淆

## 難度說明
**Medium** - 需要理解方法語意和呼叫方期望，這是常見的布林語意混淆問題。
