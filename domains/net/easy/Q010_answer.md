# Q010 解答：WebAddress 默認端口錯誤

## 問題根因

在 `WebAddress.java` 的構造函數中，HTTP 的默認端口被錯誤地設置為 8080。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/WebAddress.java`

**問題代碼**:

```java
public WebAddress(String address) throws ParseException {
    // ...
    
    /* Get port from scheme or scheme from port, if necessary and
       possible */
    if (mPort == 443 && mScheme.equals("")) {
        mScheme = "https";
    } else if (mPort == -1) {
        if (mScheme.equals("https"))
            mPort = 443;
        else
            mPort = 8080; // Bug: HTTP 默認應該是 80
    }
    if (mScheme.equals("")) mScheme = "http";
}
```

## 修復方案

將 HTTP 默認端口修正為 80：

```java
} else if (mPort == -1) {
    if (mScheme.equals("https"))
        mPort = 443;
    else
        mPort = 80; // ← 正確：HTTP 默認端口是 80
}
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.WebAddressTest#testDefaultPort
   ```

## 學習要點

- HTTP 標準端口是 80
- HTTPS 標準端口是 443
- 8080 是常見的開發/代理端口，但不是標準端口
- URL 規範定義了每個 scheme 的默認端口
