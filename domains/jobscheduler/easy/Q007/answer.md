# Q007: 答案解析

## 問題根因
`JobInfo` 類中 `isPeriodic()` 方法的判斷邏輯錯誤。

## Bug 位置
`frameworks/base/core/java/android/app/job/JobInfo.java`

## 錯誤代碼
```java
public boolean isPeriodic() {
    return intervalMillis <= 0;  // BUG: 應該是 > 0
}
```

## 正確代碼
```java
public boolean isPeriodic() {
    return intervalMillis > 0;
}
```

## 修復步驟
1. 打開 `frameworks/base/core/java/android/app/job/JobInfo.java`
2. 找到 `isPeriodic()` 方法
3. 將 `intervalMillis <= 0` 改為 `intervalMillis > 0`

## 測試驗證
```bash
atest android.jobscheduler.cts.TimingConstraintsTest#testSchedulePeriodic
atest android.jobscheduler.cts.TimingConstraintsTest#testSchedulePeriodic_lowFlex
```

## 相關知識點
- 週期性作業的 intervalMillis 大於 0 表示是週期性作業
- JobScheduler 根據 `isPeriodic()` 決定作業完成後是否重新排程
- 週期性作業有最小週期限制 (`getMinPeriodMillis()`)

## 調試命令
```bash
# 查看所有待執行的作業
adb shell cmd jobscheduler get-job-state <package> <jobId>
```
