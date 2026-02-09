# Q006 解答：MailTo.getTo 返回錯誤欄位

## 問題根因

在 `MailTo.java` 的 `getTo()` 方法中，使用了錯誤的 key 來查詢 HashMap。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/MailTo.java`

**問題代碼**:

```java
// Well known headers
static private final String TO = "to";
static private final String BODY = "body";
static private final String CC = "cc";
static private final String SUBJECT = "subject";

public String getTo() {
    return mHeaders.get(SUBJECT);  // Bug: 應該用 TO
}
```

## 修復方案

使用正確的 key：

```java
public String getTo() {
    return mHeaders.get(TO);  // ← 正確：使用 TO 作為 key
}
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.MailToTest#testGetTo
   ```

## 學習要點

- 複製貼上時要仔細修改參數
- getter 方法應該返回對應欄位的值
- 使用常量而不是硬編碼字符串有助於避免拼寫錯誤
