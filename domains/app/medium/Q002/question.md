# Q002: Activity 生命周期回調順序錯誤

## CTS 測試失敗現象

執行 `android.app.cts.ActivityCallbacksTest#testActivityCallbackOrder` 失敗

```
FAILURE: testActivityCallbackOrder
java.lang.AssertionError: Lists differ at index 3
Expected: (APPLICATION_ACTIVITY_CALLBACK, ON_CREATE)
Actual: (ACTIVITY_CALLBACK, ON_CREATE)

Full expected order for onCreate phase:
  [APP_CALLBACK, ON_PRE_CREATE]
  [ACTIVITY_CALLBACK, ON_PRE_CREATE]
  [ACTIVITY, ON_PRE_CREATE]
  [APP_CALLBACK, ON_CREATE]         <-- Expected
  [ACTIVITY_CALLBACK, ON_CREATE]    <-- Actual (wrong order)
```

## 測試代碼片段

```java
@Test
public void testActivityCallbackOrder() throws InterruptedException {
    // 註冊 Application.ActivityLifecycleCallbacks
    application.registerActivityLifecycleCallbacks(mActivityCallbacks);
    
    mActivityRule.launchActivity(null);
    
    // 驗證回調順序
    ArrayList<Pair<Source, Event>> expectedEvents = new ArrayList<>();
    addNestedEvents(expectedEvents, ON_PRE_CREATE, ON_CREATE, ON_POST_CREATE);
    // ...
    
    assertEquals(expectedEvents, actualEvents);
}
```

## 症狀描述

- Application 和 Activity 都有生命周期回調
- 在上升生命周期（onCreate, onStart, onResume）中，Application callback 應該先於 Activity callback
- 實際順序相反，Activity callback 先執行

## 你的任務

1. 理解 Activity 生命周期回調的調用機制
2. 找出回調順序錯誤的原因
3. 需要追蹤 Activity.performCreate() 中的調用順序
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/Activity.java`
  - `frameworks/base/core/java/android/app/Application.java`
- 關注 `Activity.performCreate()` 和 `dispatchActivityCreated()` 方法
- 關注 Application 中 callbacks 的迭代順序
