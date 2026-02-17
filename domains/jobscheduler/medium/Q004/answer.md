# Q004: 答案解析

## 問題根因
兩個檔案中的 bug 共同導致網絡轉換時作業被錯誤停止：
1. `ConnectivityController.java` 的變化偵測邏輯錯誤，導致錯誤地標記作業狀態改變
2. `JobStatus.java` 的 `isConstraintSatisfied` 對網絡約束使用錯誤的位運算

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/ConnectivityController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 1 - ConnectivityController.java
```java
final boolean wasSatisfied = js.isConstraintSatisfied(CONSTRAINT_CONNECTIVITY);
final boolean isSatisfied = updateConstraintsSatisfied(js, availableNetworks);
// BUG: 條件錯誤，應該是 wasSatisfied != isSatisfied
if (wasSatisfied || !isSatisfied) {
    mChangedJobs.add(js);
}
```

## 正確代碼 1
```java
final boolean wasSatisfied = js.isConstraintSatisfied(CONSTRAINT_CONNECTIVITY);
final boolean isSatisfied = updateConstraintsSatisfied(js, availableNetworks);
if (wasSatisfied != isSatisfied) {
    mChangedJobs.add(js);
}
```

## 錯誤代碼 2 - JobStatus.java
```java
public boolean isConstraintSatisfied(int constraint) {
    // BUG: 對 CONNECTIVITY 約束使用 XOR，導致結果錯誤
    if (constraint == CONSTRAINT_CONNECTIVITY) {
        return (satisfiedConstraints ^ constraint) != 0;
    }
    return (satisfiedConstraints & constraint) != 0;
}
```

## 正確代碼 2
```java
public boolean isConstraintSatisfied(int constraint) {
    return (satisfiedConstraints & constraint) != 0;
}
```

## 調試步驟
1. 在 `ConnectivityController` 中添加 log：
```java
Slog.d(TAG, "updateTrackedJobs: job=" + js.toShortString() 
        + ", wasSatisfied=" + wasSatisfied + ", isSatisfied=" + isSatisfied);
```

2. 在 `JobStatus.isConstraintSatisfied` 中添加 log：
```java
Slog.d(TAG, "isConstraintSatisfied: constraint=" + Integer.toHexString(constraint)
        + ", satisfied=" + Integer.toHexString(satisfiedConstraints)
        + ", result=" + ((satisfiedConstraints & constraint) != 0));
```

3. 執行測試並查看 log：
```bash
adb logcat -s JobScheduler.Connectivity JobScheduler.JobStatus
```

## 修復步驟
1. 打開 `ConnectivityController.java`，修正條件判斷為 `wasSatisfied != isSatisfied`
2. 打開 `JobStatus.java`，移除對 `CONSTRAINT_CONNECTIVITY` 的特殊處理

## 測試驗證
```bash
atest android.jobscheduler.cts.ConnectivityConstraintTest#testConnectivityConstraintExecutes_transitionNetworks
atest android.jobscheduler.cts.ConnectivityConstraintTest#testConnectivityConstraintExecutes
```

## 相關知識點
- 位運算 `&` (AND) 用於檢查特定位是否設置
- 位運算 `^` (XOR) 用於切換位或比較差異
- 狀態變化偵測應該比較變化前後的狀態差異
