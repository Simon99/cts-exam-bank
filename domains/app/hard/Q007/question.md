# Q007: Fragment BackStack 狀態恢復失敗

## CTS 測試失敗現象

執行 `android.app.cts.FragmentManagerTest#testBackStackStateRestore` 失敗

```
FAILURE: testBackStackStateRestore
junit.framework.AssertionFailedError: 
    Fragment state lost after configuration change
    
    Before rotation:
      - BackStack depth: 3
      - Top fragment: DetailFragment
      - Saved instance data: "user_data_123"
    
    After rotation:
      - BackStack depth: 1
      - Top fragment: MainFragment
      - Saved instance data: null
    
    Expected BackStack to be fully restored
    
    at android.app.cts.FragmentManagerTest.testBackStackStateRestore(FragmentManagerTest.java:523)
```

## 測試代碼片段

```java
@Test
public void testBackStackStateRestore() throws Exception {
    // 添加多層 Fragment 到 BackStack
    FragmentTransaction ft1 = fm.beginTransaction();
    ft1.replace(R.id.container, new MainFragment());
    ft1.addToBackStack("main");
    ft1.commit();
    
    FragmentTransaction ft2 = fm.beginTransaction();
    ft2.replace(R.id.container, new ListFragment());
    ft2.addToBackStack("list");
    ft2.commit();
    
    FragmentTransaction ft3 = fm.beginTransaction();
    DetailFragment detail = new DetailFragment();
    detail.setData("user_data_123");
    ft3.replace(R.id.container, detail);
    ft3.addToBackStack("detail");
    ft3.commit();
    
    fm.executePendingTransactions();
    
    assertEquals(3, fm.getBackStackEntryCount());
    
    // 模擬配置變更（如螢幕旋轉）
    Bundle savedState = new Bundle();
    activity.onSaveInstanceState(savedState);
    
    // 重建 Activity
    recreateActivity();
    activity.onCreate(savedState);
    
    // 驗證 BackStack 恢復
    assertEquals(3, fm.getBackStackEntryCount());
    Fragment topFragment = fm.findFragmentById(R.id.container);
    assertTrue(topFragment instanceof DetailFragment);
    assertEquals("user_data_123", ((DetailFragment) topFragment).getData());
}
```

## 症狀描述

- 多層 Fragment 事務添加到 BackStack
- 配置變更後 Activity 重建
- BackStack 沒有正確恢復，丟失了中間層
- Fragment 的 savedInstanceState 數據丟失

## 你的任務

1. 追蹤 FragmentManager 的狀態保存和恢復流程
2. 分析 BackStackRecord 是如何被序列化的
3. 找出狀態丟失發生在哪個環節
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/FragmentManager.java`
  - `frameworks/base/core/java/android/app/BackStackRecord.java`
  - `frameworks/base/core/java/android/app/FragmentState.java`
- 關注 `FragmentManager.saveAllState()` 方法
- 關注 `BackStackRecord.saveState()` 的實現
