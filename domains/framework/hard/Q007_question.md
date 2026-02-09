# Q007: Intent 序列化時 Categories 集合線程安全問題

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testCategoriesConcurrency FAILED

java.util.ConcurrentModificationException
    at java.util.ArraySet$1.next(ArraySet.java:345)
    at android.content.Intent.writeToParcel(Intent.java:11234)
    at android.content.cts.IntentTest.testCategoriesConcurrency(IntentTest.java:2567)
```

## 測試代碼片段

```java
@Test
public void testCategoriesConcurrency() throws Exception {
    final Intent intent = new Intent();
    intent.addCategory(Intent.CATEGORY_DEFAULT);
    intent.addCategory(Intent.CATEGORY_BROWSABLE);
    
    final CountDownLatch latch = new CountDownLatch(2);
    final AtomicBoolean failed = new AtomicBoolean(false);
    
    // Thread 1: 持續添加 category
    Thread adder = new Thread(() -> {
        for (int i = 0; i < 1000; i++) {
            intent.addCategory("category_" + i);
        }
        latch.countDown();
    });
    
    // Thread 2: 持續序列化
    Thread serializer = new Thread(() -> {
        for (int i = 0; i < 100; i++) {
            Parcel parcel = Parcel.obtain();
            try {
                intent.writeToParcel(parcel, 0);
            } catch (ConcurrentModificationException e) {
                failed.set(true);
            }
            parcel.recycle();
        }
        latch.countDown();
    });
    
    adder.start();
    serializer.start();
    latch.await(10, TimeUnit.SECONDS);
    
    assertFalse("ConcurrentModificationException detected", failed.get());
}
```

## 背景信息

- Intent 的 categories 是一個 ArraySet
- 多線程環境下可能同時讀寫
- 涉及 Intent 序列化和集合同步

## 你的任務

1. 分析線程安全問題的原因
2. 找出缺少同步的位置
3. 理解 Intent 在多線程環境下的使用
4. 提供修復方案
