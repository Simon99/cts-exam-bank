# Q005: MailTo.isMailTo 判斷錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.MailToTest#testIsMailTo

junit.framework.AssertionFailedError: expected true but was false
    at android.net.cts.MailToTest.testIsMailTo(MailToTest.java:32)
```

## 測試代碼片段

```java
@Test
public void testIsMailTo() {
    assertTrue(MailTo.isMailTo("mailto:test@example.com"));  // ← 這裡失敗
    assertTrue(MailTo.isMailTo("mailto:"));
    assertFalse(MailTo.isMailTo("http://example.com"));
    assertFalse(MailTo.isMailTo(null));
}
```

## 問題描述

`MailTo.isMailTo()` 方法無法正確識別 `mailto:` 開頭的 URL。
即使 URL 明確以 `mailto:` 開頭，方法仍然返回 `false`。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：字符串比較、scheme
