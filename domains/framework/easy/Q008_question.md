# Q008: Bundle.getBoolean() 預設值錯誤

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testGetBoolean2 FAILED

java.lang.AssertionError: expected:<true> but was:<false>
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.os.cts.BundleTest.testGetBoolean2(BundleTest.java:268)
```

## 測試代碼片段

```java
@Test
public void testGetBoolean2() {
    assertTrue(mBundle.getBoolean(KEY1, true));  // 使用預設值 true，但返回 false
    mBundle.putBoolean(KEY1, false);
    assertFalse(mBundle.getBoolean(KEY1, true));
}
```

## 背景信息

- `getBoolean(key, defaultValue)` 在 key 不存在時返回 defaultValue
- 這是帶預設值的獲取模式
- 與 getInt 的 defaultValue 處理類似

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
