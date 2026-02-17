# Q006: MailTo.getTo 返回錯誤欄位

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.MailToTest#testGetTo

junit.framework.AssertionFailedError: 
Expected: test@example.com
Actual: Hello World
    at android.net.cts.MailToTest.testGetTo(MailToTest.java:48)
```

## 測試代碼片段

```java
@Test
public void testGetTo() throws ParseException {
    MailTo mailTo = MailTo.parse("mailto:test@example.com?subject=Hello%20World");
    
    assertEquals("test@example.com", mailTo.getTo());  // ← 失敗
    assertEquals("Hello World", mailTo.getSubject());
}
```

## 問題描述

調用 `MailTo.getTo()` 時，返回的不是收件人地址，
而是其他欄位（如 subject）的值。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：HashMap、key、getter
