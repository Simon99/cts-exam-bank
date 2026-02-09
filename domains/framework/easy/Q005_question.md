# Q005: Intent.getStringExtra() 返回 null

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testGetStringExtra FAILED

java.lang.AssertionError: expected:<test_string> but was:<null>
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.content.cts.IntentTest.testGetStringExtra(IntentTest.java:523)
```

## 測試代碼片段

```java
@Test
public void testGetStringExtra() {
    assertNull(mIntent.getStringExtra(TEST_EXTRA_NAME));
    mIntent.putExtra(TEST_EXTRA_NAME, "test_string");
    assertEquals("test_string", mIntent.getStringExtra(TEST_EXTRA_NAME));
}
```

## 背景信息

- Intent 使用 extras Bundle 存儲額外數據
- `putExtra()` 和 `getStringExtra()` 是常用的 Intent 數據傳遞方式
- 這是 Android 組件間通訊的基礎

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
