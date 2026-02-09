# Q005: Fragment 添加後 isAdded() 返回錯誤

## CTS 測試失敗現象

執行 `android.app.cts.FragmentTransactionTest#testAddTransactionWithValidFragment` 失敗

```
FAILURE: testAddTransactionWithValidFragment
java.lang.AssertionError: expected true but was false
    at android.app.cts.FragmentTransactionTest.testAddTransactionWithValidFragment(FragmentTransactionTest.java:58)

Fragment.isAdded() returned false after successful add transaction
```

## 測試代碼片段

```java
@Test
public void testAddTransactionWithValidFragment() {
    final Fragment fragment = new CorrectFragment();
    InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
        @Override
        public void run() {
            mActivity.getFragmentManager().beginTransaction()
                    .add(R.id.content, fragment)
                    .addToBackStack(null)
                    .commit();
            mActivity.getFragmentManager().executePendingTransactions();
        }
    });
    InstrumentationRegistry.getInstrumentation().waitForIdleSync();
    
    assertTrue(fragment.isAdded());  // 失敗！返回 false
}
```

## 症狀描述

- 使用 FragmentTransaction 添加 Fragment
- 調用 commit() 和 executePendingTransactions()
- Fragment.isAdded() 返回 false
- Fragment 應該已經被添加到 Activity

## 你的任務

1. 分析 Fragment 添加流程和狀態管理
2. 找出為什麼 isAdded() 返回 false
3. 追蹤 FragmentManager 的 addFragment 流程
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/Fragment.java`
  - `frameworks/base/core/java/android/app/FragmentManager.java`
- 關注 `mAdded` 標誌的設置
- 追蹤 `moveToState()` 方法
