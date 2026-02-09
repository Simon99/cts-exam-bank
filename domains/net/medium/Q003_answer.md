# Q003 解答：MailTo.parse() 解析帶有編碼字符的 subject 時返回 null

## 問題根因

`MailTo.java` 的 `parse()` 方法中，使用 `split("=")` 分割 query 參數時沒有限制分割次數。

當 subject 值本身包含 `=` 符號或特殊編碼時，會被錯誤分割。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/MailTo.java`

**問題代碼** (約第 71 行):

```java
String[] nameval = q.split("=");  // Bug: 沒有限制分割次數
```

## 問題分析

URL: `mailto:test@example.com?subject=Hello%20World&body=Test`

當解析 `subject=Hello%20World` 時：
- `split("=")` 會在每個 `=` 處分割
- 如果 `%20` 被某些情況解碼後值包含 `=`，會導致 split 出問題

更明顯的例子：`subject=a=b`
- `split("=")` → `["subject", "a", "b"]`
- `nameval.length > 1` 為 true
- 但 `nameval[1]` 只是 `"a"`，丟失了 `"=b"` 部分

## 修復方案

```java
String[] nameval = q.split("=", 2);  // 正確：最多分割成 2 部分
```

這樣：
- `subject=a=b` → `["subject", "a=b"]`
- `nameval[1]` = `"a=b"` ✓

## 驗證命令

```bash
atest android.net.cts.MailToTest#testParseEncodedSubject
```

## 學習要點

- `String.split(regex)` 會分割所有匹配項
- `String.split(regex, limit)` 限制最多返回 `limit` 個元素
- URL 參數值可能包含 `=` 符號
- 解析 key=value 格式時，應使用 `split("=", 2)`
