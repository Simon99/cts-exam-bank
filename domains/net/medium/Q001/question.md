# Q001: Uri.getQueryParameter 返回 null，但 URL 確實包含該參數

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.UriTest#testGetQueryParameter

junit.framework.AssertionFailedError: 
Expected: "hello world"
Actual: null
    at android.net.cts.UriTest.testGetQueryParameter(UriTest.java:156)
```

## 測試代碼片段

```java
@Test
public void testGetQueryParameter() {
    String url = "http://example.com/search?q=hello+world&lang=en";
    Uri uri = Uri.parse(url);
    
    // 測試基本查詢參數
    assertEquals("en", uri.getQueryParameter("lang"));  // ← 這個通過
    
    // 測試包含 + 號的參數值
    assertEquals("hello world", uri.getQueryParameter("q"));  // ← 這個失敗，返回 null
}
```

## 問題描述

URL 查詢參數中包含 `+` 符號（表示空格），`Uri.getQueryParameter()` 應該正確解碼並返回 "hello world"，但實際返回 `null`。

從代碼追蹤：
- `Uri.java` 的 `getQueryParameter()` 調用了 `UriCodec.decode()` 進行解碼
- 解碼過程中對 `+` 號的處理可能有問題

## 任務

1. 追蹤 `Uri.getQueryParameter()` 的實現
2. 找到它如何調用 `UriCodec.decode()`
3. 定位解碼過程中的 bug
4. 修復該問題

## 提示

- 涉及文件數：2（Uri.java, UriCodec.java）
- 難度：Medium
- 關鍵字：decode、convertPlus、+、space
