# Q006: Bundle.isEmpty() 判斷錯誤

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testIsEmpty FAILED

java.lang.AssertionError: expected:<false> but was:<true>
    at org.junit.Assert.assertFalse(Assert.java:65)
    at android.os.cts.BundleTest.testIsEmpty(BundleTest.java:135)
```

## 測試代碼片段

```java
@Test
public void testIsEmpty() {
    assertTrue(mBundle.isEmpty());
    mBundle.putString(KEY1, "value");
    assertFalse(mBundle.isEmpty());  // 這裡失敗
}
```

## 背景信息

- `isEmpty()` 用於判斷 Bundle 是否為空
- put 數據後，Bundle 不應該再是空的
- 這是 Bundle 基本的狀態檢查方法

## 你的任務

1. 找到導致此測試失敗的 bug
2. 定位到具體的源碼檔案和行數
3. 說明 bug 的根本原因
4. 提供修復方案
