# Q006: Bundle SparseArray 序列化邊界錯誤

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testSparseArrayParcel FAILED

java.lang.ArrayIndexOutOfBoundsException: length=5; index=7
    at android.util.SparseArray.put(SparseArray.java:245)
    at android.os.Parcel.readSparseArray(Parcel.java:3456)
    at android.os.cts.BundleTest.testSparseArrayParcel(BundleTest.java:1678)
```

## 測試代碼片段

```java
@Test
public void testSparseArrayParcel() {
    SparseArray<String> sparse = new SparseArray<>();
    sparse.put(0, "zero");
    sparse.put(5, "five");
    sparse.put(10, "ten");
    sparse.put(100, "hundred");
    sparse.put(Integer.MAX_VALUE, "max");
    
    mBundle.putSparseParcelableArray("sparse", sparse);
    
    Parcel parcel = Parcel.obtain();
    mBundle.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    Bundle restored = Bundle.CREATOR.createFromParcel(parcel);
    SparseArray<String> restoredSparse = restored.getSparseParcelableArray("sparse");
    
    assertEquals(5, restoredSparse.size());
    assertEquals("max", restoredSparse.get(Integer.MAX_VALUE));
}
```

## 背景信息

- SparseArray 使用 int 作為 key，支持稀疏存儲
- 序列化時需要正確處理 key 和 value 的數量
- 涉及 Bundle、Parcel、SparseArray 的交互

## 你的任務

1. 追蹤 SparseArray 的序列化流程
2. 找出邊界錯誤的原因
3. 理解 SparseArray 的內部結構
4. 提供修復方案
