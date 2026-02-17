# Q005 解答：MailTo.isMailTo 判斷錯誤

## 問題根因

在 `MailTo.java` 的 `isMailTo()` 方法中，字符串比較邏輯被錯誤地反轉了。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/MailTo.java`

**問題代碼**:

```java
static public final String MAILTO_SCHEME = "mailto:";

public static boolean isMailTo(String url) {
    if (url != null && url.startsWith(MAILTO_SCHEME)) {
        return false;  // Bug: 應該返回 true
    }
    return true;      // Bug: 應該返回 false
}
```

## 修復方案

反轉返回值邏輯：

```java
public static boolean isMailTo(String url) {
    if (url != null && url.startsWith(MAILTO_SCHEME)) {
        return true;   // ← 正確：匹配時返回 true
    }
    return false;      // ← 正確：不匹配時返回 false
}
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.MailToTest#testIsMailTo
   ```

## 學習要點

- Boolean 返回值邏輯要仔細檢查
- 方法名和返回值語義要一致
- `startsWith` 是檢查 URL scheme 的常用方法
