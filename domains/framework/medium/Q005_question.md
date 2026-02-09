# Q005: Bundle putAll 沒有正確合併

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testPutAll FAILED

java.lang.AssertionError: After putAll, bundle should contain all keys
expected:<3> but was:<1>
    at android.os.cts.BundleTest.testPutAll(BundleTest.java:756)
```

## 測試代碼片段

```java
@Test
public void testPutAll() {
    mBundle.putString("key1", "value1");
    
    Bundle other = new Bundle();
    other.putString("key2", "value2");
    other.putInt("key3", 100);
    
    mBundle.putAll(other);
    
    assertEquals(3, mBundle.size());  // 這裡失敗，只有 1 個
    assertEquals("value1", mBundle.getString("key1"));
    assertEquals("value2", mBundle.getString("key2"));
    assertEquals(100, mBundle.getInt("key3"));
}
```

## 背景信息

- `putAll()` 應該將另一個 Bundle 的所有內容合併到當前 Bundle
- 原有的數據應該保留
- 這是 Bundle 常用的合併操作

## 你的任務

1. 找到導致此測試失敗的 bug
2. 追蹤 putAll 的實現邏輯
3. 說明 bug 的根本原因
4. 提供修復方案
