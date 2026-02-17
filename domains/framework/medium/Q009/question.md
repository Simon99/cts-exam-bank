# Q009: Intent resolveType 返回錯誤類型

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testResolveType FAILED

java.lang.AssertionError: ResolveType should prioritize explicit type
expected:<text/html> but was:<text/plain>
    at android.content.cts.IntentTest.testResolveType(IntentTest.java:1456)
```

## 測試代碼片段

```java
@Test
public void testResolveType() {
    // 設置顯式 type
    mIntent.setType("text/html");
    // 設置 data URI (其 MIME type 是 text/plain)
    mIntent.setData(Uri.parse("content://test/item"));
    
    // resolveType 應該優先返回顯式設置的 type
    assertEquals("text/html", mIntent.resolveType(mContext));  // 失敗
}
```

## 背景信息

- Intent 可以有顯式設置的 type（通過 setType）
- Intent 也可以從 data URI 推斷 type
- `resolveType()` 應該優先返回顯式 type

## 你的任務

1. 找到導致此測試失敗的 bug
2. 理解 resolveType 的優先級邏輯
3. 說明 bug 的根本原因
4. 提供修復方案
