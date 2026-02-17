# Q002: Bundle.getInt() 預設值處理錯誤

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testGetInt2 FAILED

java.lang.AssertionError: expected:<100> but was:<0>
    at org.junit.Assert.assertEquals(Assert.java:645)
    at android.os.cts.BundleTest.testGetInt2(BundleTest.java:312)
```

## 測試代碼片段

```java
@Test
public void testGetInt2() {
    assertEquals(100, mBundle.getInt(KEY1, 100));  // 使用預設值
    mBundle.putInt(KEY1, 1);
    assertEquals(1, mBundle.getInt(KEY1, 100));
    roundtrip();
    assertEquals(1, mBundle.getInt(KEY1, 100));
}
```

## 背景信息

- `getInt(key, defaultValue)` 方法應該在 key 不存在時返回 defaultValue
- 當 key 存在時，應該返回實際存儲的值
- 這是 Bundle 常用的帶預設值獲取模式

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
