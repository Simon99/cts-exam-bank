# Q001: Bundle.getString() 返回錯誤值

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testGetString1 FAILED

java.lang.AssertionError: expected:<test_value> but was:<null>
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.os.cts.BundleTest.testGetString1(BundleTest.java:245)
```

## 測試代碼片段

```java
@Test
public void testGetString1() {
    assertNull(mBundle.getString(KEY1));
    mBundle.putString(KEY1, "test_value");
    assertEquals("test_value", mBundle.getString(KEY1));
    roundtrip();
    assertEquals("test_value", mBundle.getString(KEY1));
}
```

## 背景信息

- 測試 Bundle 的基本 String 存取功能
- `putString()` 後立即 `getString()` 應該返回相同值
- 這是 Bundle 最基本的功能之一

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
