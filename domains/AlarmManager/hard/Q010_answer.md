# Q010 Answer: Battery Saver Exact Alarm Handling

## 正確答案
**B. `adjustDeliveryTimeBasedOnBatterySaver()` 在檢查 isExact() 前就已經調整了時間**

## 問題根因
在 `AlarmManagerService.java` 的 `adjustDeliveryTimeBasedOnBatterySaver()` 方法中，
應該先檢查鬧鐘是否為精確類型，精確鬧鐘豁免於電池節省延遲。
但 bug 版本先進行了時間調整，然後才檢查是否需要豁免，
但此時已經修改了原始觸發時間，豁免邏輯無法恢復。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
long adjustDeliveryTimeBasedOnBatterySaver(Alarm alarm) {
    // BUG: 先調整了時間
    long adjustedTime = alarm.whenElapsed + mBatterySaverDelay;
    
    // 然後才檢查豁免，但 adjustedTime 已經被修改
    if (alarm.isExact()) {
        return alarm.whenElapsed;  // 試圖返回原值，但邏輯順序錯誤
    }
    return adjustedTime;
}

// 正確的代碼
long adjustDeliveryTimeBasedOnBatterySaver(Alarm alarm) {
    // 先檢查豁免條件
    if (alarm.isExact() || alarm.isAlarmClock()) {
        return alarm.whenElapsed;  // 精確鬧鐘不調整
    }
    
    // 只有非精確鬧鐘才延遲
    return alarm.whenElapsed + mBatterySaverDelay;
}
```

## 相關知識
- 精確鬧鐘設計用於時間敏感任務，應豁免於電池優化
- Battery Saver 模式會延遲非必要的後台活動
- 檢查順序很重要：先判斷豁免，再進行調整

## 難度說明
**Hard** - 需要理解電池優化的豁免機制，以及程式碼順序對結果的影響。
