# Q010 解答：SslCertificate.restoreState() 恢復後 getValidNotBefore() 返回 null

## 問題根因

問題涉及兩個檔案的交互：
1. `SslCertificate.java` 中 `X509_CERTIFICATE` 常量與 `VALID_NOT_BEFORE` 重複
2. `SslError.java` 在 saveState 時使用了錯誤的 key

## Bug 位置

1. **SslCertificate.java** - 常量定義
2. **SslError.java** - saveState/getCertificate 方法

## 錯誤代碼 - SslCertificate.java

```java
private static final String VALID_NOT_BEFORE = "valid-not-before";
private static final String VALID_NOT_AFTER = "valid-not-after";
private static final String X509_CERTIFICATE = "valid-not-before";  // Bug: 與上面重複
```

## 錯誤代碼 - SslError.java

```java
public Bundle saveState() {
    Bundle state = new Bundle();
    // BUG: 使用 "cert" 而非 "certificate"，與 restoreState 不一致
    state.putBundle("cert", SslCertificate.saveState(mCertificate));
    state.putInt("primary_error", mPrimaryError);
    return state;
}

public SslCertificate getCertificate() {
    // BUG: 沒有從 savedState 正確恢復
    if (mCertificate == null && mSavedState != null) {
        return null;  // 應該調用 restoreState
    }
    return mCertificate;
}
```

## 問題分析

### SslCertificate.java
在 `saveState()` 中：
```java
bundle.putString(VALID_NOT_BEFORE, ...);  // key = "valid-not-before"
bundle.putByteArray(X509_CERTIFICATE, ...);  // key = "valid-not-before" (覆蓋！)
```

### SslError.java
saveState 使用 "cert"，但 restoreState 可能期望 "certificate"。

## 修復方案

### SslCertificate.java
```java
private static final String X509_CERTIFICATE = "x509-certificate";  // 使用正確的 key
```

### SslError.java
```java
public Bundle saveState() {
    Bundle state = new Bundle();
    state.putBundle("certificate", SslCertificate.saveState(mCertificate));
    state.putInt("primary_error", mPrimaryError);
    state.putString("url", mUrl);
    return state;
}
```

## 驗證命令

```bash
atest android.net.http.cts.SslCertificateTest#testSaveAndRestoreState
```

## 學習要點

- Bundle 的 key 必須唯一
- 常量複製時容易出錯
- save/restore 使用的 key 必須一致
- 多個檔案之間的交互需要仔細檢查
