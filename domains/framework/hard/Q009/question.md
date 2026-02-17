# Q009: ContentResolver notifyChange Flags 位掩碼處理錯誤

## CTS 測試失敗現象

```
android.content.cts.ContentResolverTest#testNotifyChangeFlags FAILED

java.lang.AssertionError: 
Expected observer to NOT receive notification (NOTIFY_SKIP_NOTIFY_FOR_DESCENDANTS set)
But notification was received
    at android.content.cts.ContentResolverTest.testNotifyChangeFlags(ContentResolverTest.java:1523)
```

## 測試代碼片段

```java
@Test
public void testNotifyChangeFlags() throws Exception {
    final Uri parentUri = Uri.parse("content://ctstest/level/");
    final Uri childUri = Uri.parse("content://ctstest/level/child");
    
    final CountDownLatch parentLatch = new CountDownLatch(1);
    final CountDownLatch childLatch = new CountDownLatch(1);
    final AtomicBoolean childNotified = new AtomicBoolean(false);
    
    // 註冊監聽子 URI
    ContentObserver childObserver = new ContentObserver(null) {
        @Override
        public void onChange(boolean selfChange, Uri uri) {
            childNotified.set(true);
            childLatch.countDown();
        }
    };
    mContentResolver.registerContentObserver(childUri, false, childObserver);
    
    // 使用 NOTIFY_SKIP_NOTIFY_FOR_DESCENDANTS flag
    // 預期：只通知 parentUri，不通知子路徑
    int flags = ContentResolver.NOTIFY_SKIP_NOTIFY_FOR_DESCENDANTS;
    mContentResolver.notifyChange(parentUri, null, flags);
    
    // 等待一小段時間
    assertFalse("Child should NOT be notified with SKIP_DESCENDANTS flag",
        childLatch.await(500, TimeUnit.MILLISECONDS));  // ← 失敗：子節點仍然收到通知
    assertFalse(childNotified.get());
    
    mContentResolver.unregisterContentObserver(childObserver);
}
```

## 問題描述

當使用 `NOTIFY_SKIP_NOTIFY_FOR_DESCENDANTS` flag 調用 `notifyChange()` 時，子 URI 的 observer 不應該收到通知。但是測試顯示子 observer 仍然收到了通知，說明 flags 沒有被正確處理。

## 相關源碼位置

- `frameworks/base/core/java/android/content/ContentResolver.java` - notifyChange() 方法
- `frameworks/base/services/core/java/com/android/server/content/ContentService.java` - 實際處理邏輯

## 調試提示

需要追蹤：
1. flags 參數在 notifyChange 調用鏈中的傳遞
2. NOTIFY_SKIP_NOTIFY_FOR_DESCENDANTS 的位掩碼處理
3. ContentService 中 flags 的檢查邏輯

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
