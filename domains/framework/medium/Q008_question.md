# Q008: Parcel readBundle ClassLoader 設置錯誤

## CTS 測試失敗現象

```
android.os.cts.ParcelTest#testReadBundleWithClassLoader FAILED

android.os.BadParcelableException: ClassNotFoundException when unmarshalling: 
com.example.CustomParcelable
    at android.os.Parcel.readParcelableInternal(Parcel.java:3456)
    at android.os.cts.ParcelTest.testReadBundleWithClassLoader(ParcelTest.java:892)
```

## 測試代碼片段

```java
@Test
public void testReadBundleWithClassLoader() {
    Bundle bundle = new Bundle();
    bundle.putParcelable("custom", new CustomParcelable("test"));
    
    Parcel parcel = Parcel.obtain();
    bundle.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    // 使用自定義 ClassLoader 讀取
    Bundle restored = parcel.readBundle(getClass().getClassLoader());
    
    CustomParcelable custom = restored.getParcelable("custom");
    assertNotNull(custom);  // 失敗
}
```

## 背景信息

- Bundle 可以包含自定義 Parcelable 對象
- 讀取時需要正確的 ClassLoader 來反序列化自定義類
- 這涉及 Bundle 和 Parcel 的 ClassLoader 傳遞

## 你的任務

1. 找到導致此測試失敗的 bug
2. 追蹤 ClassLoader 如何傳遞到 Bundle
3. 說明 bug 的根本原因
4. 提供修復方案
