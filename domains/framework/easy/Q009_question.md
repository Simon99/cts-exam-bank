# Q009: Bundle.remove() 無法刪除 key

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testRemove FAILED

java.lang.AssertionError: expected:<false> but was:<true>
    at org.junit.Assert.assertFalse(Assert.java:65)
    at android.os.cts.BundleTest.testRemove(BundleTest.java:195)
```

## 測試代碼片段

```java
@Test
public void testRemove() {
    mBundle.putString(KEY1, "value");
    assertTrue(mBundle.containsKey(KEY1));
    mBundle.remove(KEY1);
    assertFalse(mBundle.containsKey(KEY1));  // 這裡失敗，remove 後仍然存在
}
```

## 背景信息

- `remove()` 方法應該從 Bundle 中刪除指定的 key
- 刪除後，`containsKey()` 應該返回 false
- 這是 Bundle 基本的刪除操作

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
