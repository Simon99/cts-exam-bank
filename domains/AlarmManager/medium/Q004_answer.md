# Q004 Answer: canScheduleExactAlarms Returns Wrong Result

## 正確答案
**B. `canScheduleExactAlarms()` 的返回值被意外取反**

## 問題根因
在 `AlarmManager.java` 的 `canScheduleExactAlarms()` 方法中，
從 service 獲取權限檢查結果後，返回值被錯誤地取反（加了 `!`），
導致有權限時返回 false，無權限時返回 true。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 1145-1155)

## 修復方式
```java
// 錯誤的代碼
public boolean canScheduleExactAlarms() {
    try {
        return !mService.hasScheduleExactAlarm(mContext.getOpPackageName(),  // BUG: 多了 !
                mContext.getUserId());
    } catch (RemoteException e) {
        throw e.rethrowFromSystemServer();
    }
}

// 正確的代碼
public boolean canScheduleExactAlarms() {
    try {
        return mService.hasScheduleExactAlarm(mContext.getOpPackageName(),
                mContext.getUserId());
    } catch (RemoteException e) {
        throw e.rethrowFromSystemServer();
    }
}
```

## 相關知識
- API 31+ 需要 SCHEDULE_EXACT_ALARM 或 USE_EXACT_ALARM 權限才能使用精確鬧鐘
- SCHEDULE_EXACT_ALARM 需要用戶手動在設定中授權
- USE_EXACT_ALARM 給予特定類別 app（如鬧鐘 app）自動授權

## 難度說明
**Medium** - 需要理解精確鬧鐘權限機制，錯誤本身是簡單的邏輯反轉。
