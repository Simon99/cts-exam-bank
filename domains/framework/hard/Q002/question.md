# Q002: Bundle 嵌套結構跨進程傳遞數據損壞

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testNestedBundleParcel FAILED

java.lang.AssertionError: Nested bundle data corrupted after parceling
Inner value expected:<inner_value> but was:<outer_value>
    at android.os.cts.BundleTest.testNestedBundleParcel(BundleTest.java:1567)
```

## 測試代碼片段

```java
@Test
public void testNestedBundleParcel() {
    Bundle inner = new Bundle();
    inner.putString("key", "inner_value");
    
    Bundle middle = new Bundle();
    middle.putBundle("inner", inner);
    middle.putString("key", "middle_value");
    
    Bundle outer = new Bundle();
    outer.putBundle("middle", middle);
    outer.putString("key", "outer_value");
    
    // Parcel 傳遞
    Parcel parcel = Parcel.obtain();
    outer.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    Bundle restored = Bundle.CREATOR.createFromParcel(parcel);
    Bundle restoredMiddle = restored.getBundle("middle");
    Bundle restoredInner = restoredMiddle.getBundle("inner");
    
    assertEquals("outer_value", restored.getString("key"));
    assertEquals("middle_value", restoredMiddle.getString("key"));
    assertEquals("inner_value", restoredInner.getString("key"));  // 失敗
}
```

## 背景信息

- Bundle 可以嵌套包含其他 Bundle
- 序列化時需要遞歸處理嵌套結構
- 涉及 Bundle 寫入、類型標記、邊界處理

## 你的任務

1. 追蹤嵌套 Bundle 的序列化流程
2. 找出數據損壞的原因
3. 理解 Bundle 嵌套序列化的機制
4. 提供修復方案
