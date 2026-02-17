# Q001: Bundle Parcel 序列化數據丟失

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testWriteToParcel FAILED

java.lang.AssertionError: expected:<test_value> but was:<null>
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.os.cts.BundleTest.testWriteToParcel(BundleTest.java:892)
```

## 測試代碼片段

```java
@Test
public void testWriteToParcel() {
    mBundle.putString(KEY1, "test_value");
    mBundle.putInt(KEY2, 100);
    
    Parcel parcel = Parcel.obtain();
    mBundle.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    Bundle restored = Bundle.CREATOR.createFromParcel(parcel);
    assertEquals("test_value", restored.getString(KEY1));  // 這裡失敗
    assertEquals(100, restored.getInt(KEY2));
}
```

## 背景信息

- Bundle 需要支援 Parcel 序列化用於 IPC
- `writeToParcel()` 寫入數據，`createFromParcel()` 讀取數據
- 這涉及 Bundle 和 BaseBundle 的序列化邏輯

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因（可能需要追蹤 writeToParcel 和 readFromParcel 的流程）
4. 提供修復方案
