# Q010 Answer: Exact Alarm Permission Check Bypassed

## 正確答案
**A. 權限檢查的結果被忽略，沒有在失敗時拋出例外**

## 問題根因
在 `AlarmManagerService.java` 的 `setImpl()` 方法中，
呼叫 `hasScheduleExactAlarmInternal()` 檢查權限後，
應該在返回 false 時拋出 SecurityException，
但 bug 程式碼只呼叫了檢查方法卻沒有處理返回值，
導致無論有無權限都繼續執行設定鬧鐘。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void setImpl(int type, long triggerAtMillis, long windowLength, ...) {
    if (windowLength == 0) {
        hasScheduleExactAlarmInternal(callingUid, callingPackage);  // BUG: 沒有處理返回值
    }
    // continue to set alarm...
}

// 正確的代碼
void setImpl(int type, long triggerAtMillis, long windowLength, ...) {
    if (windowLength == 0) {
        if (!hasScheduleExactAlarmInternal(callingUid, callingPackage)) {
            throw new SecurityException("Caller does not have SCHEDULE_EXACT_ALARM permission");
        }
    }
    // continue to set alarm...
}
```

## 相關知識
- API 31+ 精確鬧鐘需要 SCHEDULE_EXACT_ALARM 或 USE_EXACT_ALARM 權限
- 這是為了減少精確鬧鐘對電池的影響
- 系統 app 和特定類別 app 有自動豁免

## 難度說明
**Medium** - 需要追蹤權限檢查流程，發現返回值被忽略的問題。
