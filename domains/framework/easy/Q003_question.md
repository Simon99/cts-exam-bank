# Q003: Bundle.containsKey() 返回錯誤結果

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testContainsKey FAILED

java.lang.AssertionError: expected:<true> but was:<false>
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.os.cts.BundleTest.testContainsKey(BundleTest.java:178)
```

## 測試代碼片段

```java
@Test
public void testContainsKey() {
    assertFalse(mBundle.containsKey(KEY1));
    mBundle.putBoolean(KEY1, true);
    assertTrue(mBundle.containsKey(KEY1));  // 這裡失敗
    roundtrip();
    assertTrue(mBundle.containsKey(KEY1));
}
```

## 背景信息

- `containsKey()` 用於檢查 Bundle 中是否存在某個 key
- 在 `putXXX()` 操作後，對應的 key 應該存在
- 這是判斷數據是否存在的基本方法

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
