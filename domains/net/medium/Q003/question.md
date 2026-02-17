# Q003: MailTo.parse() 解析帶有編碼字符的 subject 時返回 null

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.MailToTest#testParseEncodedSubject

junit.framework.AssertionFailedError: 
Expected: "Hello World"
Actual: null
    at android.net.cts.MailToTest.testParseEncodedSubject(MailToTest.java:87)
```

## 測試代碼片段

```java
@Test
public void testParseEncodedSubject() throws Exception {
    String mailtoUrl = "mailto:test@example.com?subject=Hello%20World&body=Test";
    
    MailTo mailto = MailTo.parse(mailtoUrl);
    
    assertEquals("test@example.com", mailto.getTo());  // ← 通過
    assertEquals("Test", mailto.getBody());            // ← 通過
    assertEquals("Hello World", mailto.getSubject());  // ← 失敗，返回 null
}
```

## 問題描述

`MailTo.parse()` 可以正確解析收件人和正文，但解析 URL 編碼的 subject（主題）時返回 null。

`%20` 是空格的 URL 編碼，應該被正確解碼為 "Hello World"。

## 相關代碼結構

`MailTo.java` 解析邏輯：
```java
public static MailTo parse(String url) throws ParseException {
    // ...
    String query = email.getQuery();
    if (query != null) {
        String[] queries = query.split("&");
        for (String q : queries) {
            String[] nameval = q.split("=");
            // 將參數名稱轉小寫後存入 headers
            m.mHeaders.put(Uri.decode(nameval[0]).toLowerCase(Locale.ROOT),
                    nameval.length > 1 ? Uri.decode(nameval[1]) : null);
        }
    }
    // ...
}
```

## 任務

1. 分析 `MailTo.parse()` 的解析邏輯
2. 找出為什麼 subject 會返回 null
3. 追蹤 `Uri.decode()` 的調用
4. 修復問題

## 提示

- 涉及文件數：2（MailTo.java, Uri.java）
- 難度：Medium
- 關鍵字：parse、decode、getSubject、toLowerCase
