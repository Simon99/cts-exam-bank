# Q010: ActivityResult 在 multi-resume 模式下丟失

## CTS 測試失敗現象

執行 `android.app.cts.ActivityResultTest#testResultDeliveryMultiResume` 失敗

```
FAILURE: testResultDeliveryMultiResume
junit.framework.AssertionFailedError: 
    Activity result not delivered in multi-resume mode
    
    Test scenario:
      - Activity A (left) and Activity B (right) both resumed (split-screen)
      - A starts Activity C for result
      - C finishes with RESULT_OK
    
    Expected: A.onActivityResult() called with RESULT_OK
    Actual: onActivityResult() never called
    
    ActivityA state: RESUMED
    Result pending: true
    
    at android.app.cts.ActivityResultTest.testResultDeliveryMultiResume(ActivityResultTest.java:289)
```

## 測試代碼片段

```java
@Test
public void testResultDeliveryMultiResume() throws Exception {
    // 設置分屏模式，A 在左邊，B 在右邊
    launchActivityInSplitScreen(ActivityA.class, ActivityB.class);
    
    // 確認兩個 Activity 都處於 RESUMED 狀態（multi-resume）
    assertTrue(isActivityResumed(mActivityA));
    assertTrue(isActivityResumed(mActivityB));
    
    final CountDownLatch resultLatch = new CountDownLatch(1);
    final AtomicInteger resultCode = new AtomicInteger(-1);
    
    mActivityA.setResultCallback((requestCode, rCode, data) -> {
        resultCode.set(rCode);
        resultLatch.countDown();
    });
    
    // A 啟動 C for result
    Intent intent = new Intent(mActivityA, ActivityC.class);
    mActivityA.startActivityForResult(intent, REQUEST_CODE);
    
    // 等待 C 完成
    waitForActivity(ActivityC.class);
    ActivityC c = getActivity(ActivityC.class);
    c.setResult(Activity.RESULT_OK);
    c.finish();
    
    // 等待 A 收到結果
    assertTrue("Result not delivered", resultLatch.await(10, TimeUnit.SECONDS));
    assertEquals(Activity.RESULT_OK, resultCode.get());
}
```

## 症狀描述

- 在分屏/多視窗模式下，多個 Activity 可以同時處於 RESUMED 狀態
- Activity A 使用 startActivityForResult 啟動 Activity C
- C finish 後，A 沒有收到 onActivityResult 回調
- 結果被系統標記為 pending 但從未傳遞

## 你的任務

1. 分析 multi-resume 模式下 Activity 的生命週期
2. 追蹤 ActivityResult 從 C finish 到 A onActivityResult 的流程
3. 找出結果傳遞被阻斷的原因
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/services/core/java/com/android/server/wm/ActivityRecord.java`
  - `frameworks/base/services/core/java/com/android/server/wm/TaskFragment.java`
  - `frameworks/base/core/java/android/app/ActivityThread.java`
- 關注 `ActivityRecord.completeResultsLocked()` 方法
- 關注 multi-resume 模式下的狀態判斷條件
