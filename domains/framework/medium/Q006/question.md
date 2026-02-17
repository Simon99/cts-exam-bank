# Q006: Intent clone 後修改影響原對象

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testClone FAILED

java.lang.AssertionError: Clone should be independent from original
Original intent modified unexpectedly
expected:<original_value> but was:<modified_value>
    at android.content.cts.IntentTest.testClone(IntentTest.java:1823)
```

## 測試代碼片段

```java
@Test
public void testClone() {
    mIntent.setAction(Intent.ACTION_VIEW);
    mIntent.putExtra("key", "original_value");
    
    Intent cloned = (Intent) mIntent.clone();
    
    // 修改 clone
    cloned.putExtra("key", "modified_value");
    
    // 原始 Intent 不應該被影響
    assertEquals("original_value", mIntent.getStringExtra("key"));  // 失敗
    assertEquals("modified_value", cloned.getStringExtra("key"));
}
```

## 背景信息

- `clone()` 應該創建 Intent 的獨立副本
- 修改 clone 不應該影響原對象
- 這涉及 Intent 的 extras Bundle 如何被拷貝

## 你的任務

1. 找到導致此測試失敗的 bug
2. 追蹤 Intent.clone() 的實現
3. 說明 bug 的根本原因
4. 提供修復方案
