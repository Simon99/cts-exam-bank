# Q004: Bundle Binder 對象序列化導致資源洩漏

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testBinderLeak FAILED

java.lang.AssertionError: Binder count increased after test
Expected binder count: 10, Actual: 15
Resource leak detected: 5 Binder objects not released
    at android.os.cts.BundleTest.testBinderLeak(BundleTest.java:1890)
```

## 測試代碼片段

```java
@Test
public void testBinderLeak() {
    int initialBinderCount = Debug.getBinderLocalObjectCount();
    
    for (int i = 0; i < 100; i++) {
        Bundle bundle = new Bundle();
        bundle.putBinder("binder", new Binder());
        
        Parcel parcel = Parcel.obtain();
        bundle.writeToParcel(parcel, 0);
        parcel.setDataPosition(0);
        
        Bundle restored = Bundle.CREATOR.createFromParcel(parcel);
        IBinder restoredBinder = restored.getBinder("binder");
        
        parcel.recycle();
        // bundle 和 restored 應該被 GC 回收
    }
    
    System.gc();
    Thread.sleep(1000);
    
    int finalBinderCount = Debug.getBinderLocalObjectCount();
    assertTrue(finalBinderCount <= initialBinderCount + 5);  // 失敗
}
```

## 背景信息

- Bundle 可以存儲 Binder 對象用於 IPC
- Binder 是稀缺資源，需要正確釋放
- 涉及 Bundle、Parcel、Binder 的生命週期管理

## 你的任務

1. 追蹤 Binder 在 Bundle 中的存儲和序列化
2. 找出導致 Binder 洩漏的原因
3. 理解 Binder 引用計數機制
4. 提供修復方案
