# Q001: 答案解析

## 問題根因
兩個檔案中存在相關的 bug：
1. `ConnectivityController.java` 中判斷網絡是否為非計量時，邏輯條件錯誤
2. `JobStatus.java` 中檢查是否有網絡約束時，位運算操作錯誤

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/ConnectivityController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 1 - ConnectivityController.java
```java
private boolean isNetworkUnmetered(NetworkCapabilities capabilities) {
    // BUG: 邏輯取反了，應該檢查有 NOT_METERED capability
    return capabilities != null 
            && !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED);
}
```

## 正確代碼 1
```java
private boolean isNetworkUnmetered(NetworkCapabilities capabilities) {
    return capabilities != null 
            && capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED);
}
```

## 錯誤代碼 2 - JobStatus.java
```java
public boolean hasConnectivityConstraint() {
    // BUG: 使用 OR (|) 而不是 AND (&)，導致永遠返回 true
    return (requiredConstraints | CONSTRAINT_CONNECTIVITY) != 0;
}
```

## 正確代碼 2
```java
public boolean hasConnectivityConstraint() {
    return (requiredConstraints & CONSTRAINT_CONNECTIVITY) != 0;
}
```

## 調試步驟
1. 在 `ConnectivityController` 中添加 log：
```java
Slog.d(TAG, "Checking unmetered for job " + job.toShortString() 
        + ", hasNotMetered=" + capabilities.hasCapability(NET_CAPABILITY_NOT_METERED));
```

2. 在 `JobStatus` 中添加 log：
```java
Slog.d(TAG, "hasConnectivityConstraint: required=" + Integer.toHexString(requiredConstraints)
        + ", CONNECTIVITY=" + Integer.toHexString(CONSTRAINT_CONNECTIVITY));
```

3. 執行測試並查看 log：
```bash
adb logcat -s JobScheduler.Connectivity JobScheduler.JobStatus
```

## 修復步驟
1. 打開 `ConnectivityController.java`，移除錯誤的取反邏輯
2. 打開 `JobStatus.java`，將位運算從 `|` 改為 `&`

## 測試驗證
```bash
atest android.jobscheduler.cts.ConnectivityConstraintTest#testUnmeteredConstraintFails_withMobile
atest android.jobscheduler.cts.ConnectivityConstraintTest#testUnmeteredConstraintFails_withMeteredWifi
```

## 相關知識點
- `NET_CAPABILITY_NOT_METERED` 表示網絡不是計量的
- 位運算 `&` 用於檢查特定位是否設置，`|` 用於設置位
- 非計量網絡通常是 WiFi（除非被設置為計量）
- 行動數據通常是計量網絡
