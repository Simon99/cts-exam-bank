# Q003 Answer: setAndAllowWhileIdle Not Bypassing Doze

## 正確答案
**A. `setAndAllowWhileIdle()` 沒有設定 FLAG_ALLOW_WHILE_IDLE flag**

## 問題根因
在 `AlarmManager.java` 的 `setAndAllowWhileIdle()` 方法中，
呼叫 `setImpl()` 時 flags 參數應該包含 `FLAG_ALLOW_WHILE_IDLE`，
但 bug 將 flags 設為 `0`，導致鬧鐘沒有 Doze 豁免權，
在 idle 模式下被系統正常延遲。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 715-717)

## 修復方式
```java
// 錯誤的代碼
public void setAndAllowWhileIdle(int type, long triggerAtMillis, PendingIntent operation) {
    setImpl(type, triggerAtMillis, WINDOW_HEURISTIC, 0, 0,  // BUG: flags 應該是 FLAG_ALLOW_WHILE_IDLE
            operation, null, null, (Handler) null, null, null);
}

// 正確的代碼
public void setAndAllowWhileIdle(int type, long triggerAtMillis, PendingIntent operation) {
    setImpl(type, triggerAtMillis, WINDOW_HEURISTIC, 0, FLAG_ALLOW_WHILE_IDLE,
            operation, null, null, (Handler) null, null, null);
}
```

## 相關知識
- FLAG_ALLOW_WHILE_IDLE 允許鬧鐘在 Doze 模式下觸發
- Doze 模式會延遲大多數鬧鐘以節省電力
- 即使有此 flag，仍有 9 分鐘最小間隔限制

## 難度說明
**Medium** - 需要理解 Doze 模式和 FLAG_ALLOW_WHILE_IDLE 的作用。
