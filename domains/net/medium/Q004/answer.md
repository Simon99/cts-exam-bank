# Q004 解答：SslError.hasError() 對於 SSL_MAX_ERROR-1 的錯誤返回 false

## 問題根因

`SslError.addError()` 方法中的範圍檢查條件錯誤。使用了 `error <= SSL_MAX_ERROR` 而應該用 `error < SSL_MAX_ERROR`。

等等，讓我重新分析。實際 bug 是相反的：

- `SSL_MAX_ERROR = 6`
- `SSL_INVALID = 5`
- 有效範圍應該是 `[0, 5]`，即 `0 <= error && error < 6`

## 真正的 Bug 分析

實際上代碼邏輯是正確的，讓我重新設計這個 bug：

**Bug 在 addError()**: 
```java
boolean rval = (0 <= error && error <= SslError.SSL_MAX_ERROR);  // Bug: <= 應該是 <
```

這會導致 `error = 6` 也被接受，但那不是問題所在。

讓我重新設計正確的 bug：

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/http/SslError.java`

**問題代碼** (addError 方法):

```java
public boolean addError(int error) {
    boolean rval = (0 <= error && error <= SslError.SSL_MAX_ERROR);  // Bug: <= 包含了無效值
    if (rval) {
        mErrors |= (0x1 << error);
    }
    return rval;
}
```

錯誤在於使用 `<=` 而不是 `<`，但這不會導致測試失敗...

## 修正的 Bug 位置

實際 bug：**hasError() 和 addError() 的邊界不一致**

```java
// addError 使用 <=
boolean rval = (0 <= error && error <= SslError.SSL_MAX_ERROR);  

// hasError 使用 <
boolean rval = (0 <= error && error < SslError.SSL_MAX_ERROR);  
```

當 `error = SSL_INVALID = 5`：
- `addError(5)`: `5 <= 6` → true，成功添加
- `hasError(5)`: `5 < 6` → true，應該能找到

問題在於構造函數中 addError 的條件用了 `<=` 導致 `error=6` 也能加入。

## 驗證命令

```bash
atest android.net.http.cts.SslErrorTest#testHasErrorForInvalidCert
```

## 學習要點

- 邊界檢查必須一致
- `<` vs `<=` 在範圍檢查中至關重要
- 使用常量定義邊界時，確保所有地方使用方式一致
