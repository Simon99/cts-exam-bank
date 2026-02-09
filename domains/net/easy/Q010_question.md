# Q010: WebAddress 默認端口錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.WebAddressTest#testDefaultPort

junit.framework.AssertionFailedError: 
Expected: 80
Actual: 8080
    at android.net.cts.WebAddressTest.testDefaultPort(WebAddressTest.java:42)
```

## 測試代碼片段

```java
@Test
public void testDefaultPort() throws ParseException {
    WebAddress addr = new WebAddress("http://example.com/path");
    
    assertEquals("http", addr.getScheme());
    assertEquals("example.com", addr.getHost());
    assertEquals(80, addr.getPort());  // ← 失敗，得到 8080
    assertEquals("/path", addr.getPath());
}
```

## 問題描述

創建 `WebAddress` 時，如果 URL 沒有明確指定端口，
HTTP 應該默認使用端口 80，但實際返回的是其他端口號。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：默認端口、HTTP、常量
