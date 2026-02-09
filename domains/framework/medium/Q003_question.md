# Q003: Bundle deepCopy 只做淺拷貝

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testDeepCopy FAILED

java.lang.AssertionError: Deep copy should not share inner Bundle
Inner bundle modified unexpectedly
    at android.os.cts.BundleTest.testDeepCopy(BundleTest.java:1056)
```

## 測試代碼片段

```java
@Test
public void testDeepCopy() {
    Bundle inner = new Bundle();
    inner.putString("innerKey", "innerValue");
    mBundle.putBundle("bundleKey", inner);
    
    Bundle deepCopy = mBundle.deepCopy();
    
    // 修改原始 inner bundle
    inner.putString("innerKey", "modified");
    
    // deepCopy 中的 inner bundle 不應該被影響
    Bundle copiedInner = deepCopy.getBundle("bundleKey");
    assertEquals("innerValue", copiedInner.getString("innerKey"));  // 失敗
}
```

## 背景信息

- `deepCopy()` 應該遞歸複製所有嵌套的 Bundle
- 深拷貝後，修改原始數據不應影響拷貝
- 這涉及 Bundle 的遞歸拷貝邏輯

## 你的任務

1. 找到導致此測試失敗的 bug
2. 理解 deepCopy 和普通 copy 的區別
3. 說明 bug 的根本原因
4. 提供修復方案
