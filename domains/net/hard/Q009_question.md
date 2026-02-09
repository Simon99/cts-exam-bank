# Q009: Uri.getQueryParameterNames() 返回重複的參數名

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.UriTest#testGetQueryParameterNames

junit.framework.AssertionFailedError: 
Query parameter names should be unique
Expected size: 3
Actual size: 5
    at android.net.cts.UriTest.testGetQueryParameterNames(UriTest.java:289)
```

## 測試代碼片段

```java
@Test
public void testGetQueryParameterNames() {
    Uri uri = Uri.parse("http://example.com?a=1&b=2&c=3&a=4&b=5");
    
    Set<String> names = uri.getQueryParameterNames();
    
    // Set 應該只包含唯一的參數名
    assertEquals(3, names.size());  // ← 失敗！返回 5
    assertTrue(names.contains("a"));
    assertTrue(names.contains("b"));
    assertTrue(names.contains("c"));
    
    // 即使有重複參數，getQueryParameterNames 也應該返回唯一集合
    assertFalse("Should use Set semantics", hasDuplicates(names));
}
```

## 問題描述

`Uri.getQueryParameterNames()` 應該返回一個 `Set<String>`（唯一的參數名集合），但實際上返回的集合包含了重複的名稱。

URL `?a=1&b=2&c=3&a=4&b=5` 應該返回 `{"a", "b", "c"}`，但返回了 5 個元素。

## 相關代碼結構

`Uri.java` 中的實現：
```java
public Set<String> getQueryParameterNames() {
    // ...
    LinkedHashSet<String> names = new LinkedHashSet<String>();
    
    String query = getEncodedQuery();
    if (query == null) {
        return Collections.emptySet();
    }
    
    // 解析 query string 並添加參數名
    // ...
    
    return Collections.unmodifiableSet(names);
}
```

解析邏輯可能涉及 `UriCodec` 和內部的 `Part` 類。

## 任務

1. 分析 `getQueryParameterNames()` 的實現
2. 追蹤 query string 的解析流程
3. 找出為什麼 Set 包含重複元素
4. 修復問題

## 提示

- 涉及文件數：3（Uri.java 的多個內部類）
- 難度：Hard
- 關鍵字：getQueryParameterNames、LinkedHashSet、add、duplicate
- 呼叫鏈：getQueryParameterNames() → 解析 query → 添加到 Set
- 提示：檢查使用的是 Set.add() 還是其他方法
