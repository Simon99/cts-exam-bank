# Q004: Intent filterEquals 比較邏輯錯誤

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testFilterEquals FAILED

java.lang.AssertionError: Intents with same filter should be equal
expected:<true> but was:<false>
    at android.content.cts.IntentTest.testFilterEquals(IntentTest.java:1589)
```

## 測試代碼片段

```java
@Test
public void testFilterEquals() {
    Intent intent1 = new Intent(Intent.ACTION_VIEW, TEST_URI);
    intent1.setType("text/plain");
    intent1.addCategory(Intent.CATEGORY_DEFAULT);
    
    Intent intent2 = new Intent(Intent.ACTION_VIEW, TEST_URI);
    intent2.setType("text/plain");
    intent2.addCategory(Intent.CATEGORY_DEFAULT);
    
    // extras 不同但 filter 相同
    intent1.putExtra("key1", "value1");
    intent2.putExtra("key2", "value2");
    
    assertTrue(intent1.filterEquals(intent2));  // 這裡失敗
}
```

## 背景信息

- `filterEquals()` 比較兩個 Intent 的"過濾"部分是否相同
- 只比較 action, data, type, categories 等，不比較 extras
- 這用於判斷兩個 Intent 是否匹配同一個 IntentFilter

## 你的任務

1. 找到導致此測試失敗的 bug
2. 理解 filterEquals 應該比較哪些字段
3. 說明 bug 的根本原因
4. 提供修復方案
