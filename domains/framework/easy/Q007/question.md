# Q007: Intent.hasExtra() 判斷錯誤

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testHasExtra FAILED

java.lang.AssertionError: expected:<true> but was:<false>
    at org.junit.Assert.assertTrue(Assert.java:41)
    at android.content.cts.IntentTest.testHasExtra(IntentTest.java:489)
```

## 測試代碼片段

```java
@Test
public void testHasExtra() {
    assertFalse(mIntent.hasExtra(TEST_EXTRA_NAME));
    mIntent.putExtra(TEST_EXTRA_NAME, "value");
    assertTrue(mIntent.hasExtra(TEST_EXTRA_NAME));  // 這裡失敗
}
```

## 背景信息

- `hasExtra()` 用於檢查 Intent 是否包含某個 extra
- putExtra 後，hasExtra 應該返回 true
- 這是檢查 Intent 數據的常用方法

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
