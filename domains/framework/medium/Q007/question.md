# Q007: Bundle keySet() 返回可修改的集合

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testKeySetImmutable FAILED

java.lang.AssertionError: Modifying keySet should not affect Bundle
expected:<2> but was:<1>
    at android.os.cts.BundleTest.testKeySetImmutable(BundleTest.java:623)
```

## 測試代碼片段

```java
@Test
public void testKeySetImmutable() {
    mBundle.putString("key1", "value1");
    mBundle.putString("key2", "value2");
    
    Set<String> keys = mBundle.keySet();
    keys.remove("key1");  // 修改 keySet
    
    // Bundle 不應該被影響
    assertEquals(2, mBundle.size());  // 失敗，size 變成 1
    assertTrue(mBundle.containsKey("key1"));  // 失敗
}
```

## 背景信息

- `keySet()` 應該返回 Bundle 所有 key 的集合
- 返回的集合不應該允許修改影響原 Bundle
- 這是防禦性編程的最佳實踐

## 你的任務

1. 找到導致此測試失敗的 bug
2. 理解為什麼 keySet 不應該允許直接修改
3. 說明 bug 的根本原因
4. 提供修復方案
