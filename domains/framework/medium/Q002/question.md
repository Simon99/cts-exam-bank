# Q002: Intent extras 在跨進程傳遞時丟失

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testParcelableExtras FAILED

java.lang.AssertionError: Bundle extras lost after parceling
Expected items: 3, Actual items: 0
    at android.content.cts.IntentTest.testParcelableExtras(IntentTest.java:1245)
```

## 測試代碼片段

```java
@Test
public void testParcelableExtras() {
    mIntent.putExtra("key1", "value1");
    mIntent.putExtra("key2", 123);
    mIntent.putExtra("key3", true);
    
    Parcel parcel = Parcel.obtain();
    mIntent.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    Intent restored = Intent.CREATOR.createFromParcel(parcel);
    Bundle extras = restored.getExtras();
    
    assertNotNull(extras);
    assertEquals(3, extras.size());  // 這裡失敗，size 為 0
    assertEquals("value1", extras.getString("key1"));
}
```

## 背景信息

- Intent 的 extras 是一個 Bundle
- Intent 序列化時需要同時序列化 extras Bundle
- 這涉及 Intent 和 Bundle 的序列化配合

## 你的任務

1. 找到導致此測試失敗的 bug
2. 追蹤 Intent.writeToParcel 和 readFromParcel 的流程
3. 說明 bug 的根本原因
4. 提供修復方案
