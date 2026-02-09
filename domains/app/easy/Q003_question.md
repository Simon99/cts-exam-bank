# Q003: IntentService 資源洩漏

## CTS 測試失敗現象

執行 `android.app.cts.IntentServiceTest#testIntentServiceLifeCycle` 失敗

```
FAILURE: testIntentServiceLifeCycle
java.lang.RuntimeException: IntentService Looper not quit after service destroyed
    at android.app.cts.IntentServiceTest.testIntentServiceLifeCycle(IntentServiceTest.java:95)

ANR detected: IntentService[TestService] handler thread still running after 30s
```

## 測試代碼片段

```java
public void testIntentServiceLifeCycle() throws Throwable {
    mContext.startService(mIntent);
    // ... wait for handling ...
    
    mContext.stopService(mIntent);
    IntentServiceStub.waitToFinish(TIMEOUT_MSEC);
    
    // 驗證 service 已完全停止
    assertFalse(IntentServiceStub.isLooperRunning());  // 失敗！Looper 仍在運行
}
```

## 症狀描述

- 啟動 IntentService 處理 Intent
- 停止 Service 後，內部的 HandlerThread Looper 仍在運行
- 導致資源洩漏和潛在的 ANR

## 你的任務

1. 找出導致 Looper 沒有正確退出的原因
2. 分析 IntentService 的生命周期管理
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/IntentService.java`
- 關注 `onDestroy()` 方法
- 查看 Looper 的 quit 機制
