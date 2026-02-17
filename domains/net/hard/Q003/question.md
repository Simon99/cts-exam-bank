# Q003: Uri.Builder 連續調用 appendPath 導致路徑錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.UriTest#testBuilderAppendPath

junit.framework.AssertionFailedError: 
Expected: "http://example.com/api/v1/users"
Actual: "http://example.com/users"
    at android.net.cts.UriTest.testBuilderAppendPath(UriTest.java:312)
```

## 測試代碼片段

```java
@Test
public void testBuilderAppendPath() {
    Uri uri = new Uri.Builder()
        .scheme("http")
        .authority("example.com")
        .appendPath("api")
        .appendPath("v1")
        .appendPath("users")
        .build();
    
    assertEquals("http://example.com/api/v1/users", uri.toString());  // ← 失敗
    
    List<String> segments = uri.getPathSegments();
    assertEquals(3, segments.size());  // ← 也失敗，只有 1 個
    assertEquals("api", segments.get(0));
    assertEquals("v1", segments.get(1));
    assertEquals("users", segments.get(2));
}
```

## 問題描述

使用 `Uri.Builder` 連續調用 `appendPath()` 時，只保留了最後一個路徑段，前面的都丟失了。

## 相關代碼結構

`Uri.java` 中的 Builder 類：
```java
public static final class Builder {
    private String scheme;
    private Part authority;
    private PathPart path;
    private Part query;
    private Part fragment;
    
    public Builder appendPath(String newSegment) {
        return path(PathPart.appendDecodedSegment(path, newSegment));
    }
    
    public Builder path(PathPart path) {
        this.path = path;
        return this;
    }
}
```

`PathPart` 類：
```java
static PathPart appendDecodedSegment(PathPart oldPart, String newSegment) {
    // ... 應該在現有路徑後追加新段落
}
```

## 任務

1. 追蹤 `appendPath()` 的實現
2. 檢查 `PathPart.appendDecodedSegment()` 的邏輯
3. 找出為什麼路徑段沒有正確累積
4. 可能需要檢查 `PathPart` 類的實現

## 提示

- 涉及文件數：3（Uri.java 中的 Builder, PathPart, Part 類）
- 難度：Hard
- 關鍵字：appendPath、PathPart、appendDecodedSegment
- 呼叫鏈：Builder.appendPath() → PathPart.appendDecodedSegment() → PathPart 構造
