# Q004: Bundle.size() 返回錯誤大小

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testSize FAILED

java.lang.AssertionError: expected:<2> but was:<1>
    at org.junit.Assert.assertEquals(Assert.java:645)
    at android.os.cts.BundleTest.testSize(BundleTest.java:158)
```

## 測試代碼片段

```java
@Test
public void testSize() {
    assertEquals(0, mBundle.size());
    mBundle.putBoolean(KEY1, true);
    assertEquals(1, mBundle.size());
    mBundle.putInt(KEY2, 100);
    assertEquals(2, mBundle.size());  // 這裡失敗
}
```

## 背景信息

- `size()` 方法返回 Bundle 中的元素數量
- 每次 put 新的 key 應該使 size 增加 1
- 這是 Bundle 基本的計數功能

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
