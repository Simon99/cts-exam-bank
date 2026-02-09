# Q004: Service 前台通知在 ANR 後消失

## CTS 測試失敗現象

執行 `android.app.cts.ServiceTest#testForegroundServiceNotificationPersistence` 失敗

```
FAILURE: testForegroundServiceNotificationPersistence
junit.framework.AssertionFailedError: 
    Foreground service notification not found after ANR recovery
    
    Expected: notification with id 12345 should exist
    Actual: notification not found in StatusBarManager
    
    Service is still running and in foreground state
    
    at android.app.cts.ServiceTest.testForegroundServiceNotificationPersistence(ServiceTest.java:567)
```

## 測試代碼片段

```java
@Test
public void testForegroundServiceNotificationPersistence() throws Exception {
    // 啟動前台服務
    Intent intent = new Intent(mContext, ForegroundTestService.class);
    mContext.startForegroundService(intent);
    
    // 等待服務進入前台狀態
    waitForServiceForeground("com.test/.ForegroundTestService");
    
    // 確認通知存在
    int notifId = 12345;
    assertTrue("Initial notification should exist", 
        isNotificationVisible(notifId));
    
    // 模擬 ANR 並恢復
    triggerAndRecoverFromAnr("com.test");
    
    // 確認服務仍在前台
    assertTrue("Service should still be foreground",
        isServiceForeground("com.test/.ForegroundTestService"));
    
    // 關鍵：通知應該仍然存在
    assertTrue("Notification should persist after ANR recovery",
        isNotificationVisible(notifId));
}
```

## 症狀描述

- 前台服務正常啟動並顯示通知
- 發生 ANR 後系統顯示「等待」或「關閉」對話框
- 用戶選擇「等待」，ANR 恢復
- 服務仍在運行且為前台狀態，但通知消失
- 違反前台服務必須有通知的約定

## 你的任務

1. 追蹤 ANR 處理流程中對 Service 和 Notification 的影響
2. 分析為什麼服務保持前台但通知丟失
3. 找出 ANR 恢復邏輯中的問題
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/services/core/java/com/android/server/am/AppErrors.java`
  - `frameworks/base/services/core/java/com/android/server/am/ActiveServices.java`
  - `frameworks/base/services/core/java/com/android/server/notification/NotificationManagerService.java`
- 關注 `AppErrors.appNotResponding()` 的處理流程
- 關注 ANR 恢復時 `ActiveServices` 的狀態同步
