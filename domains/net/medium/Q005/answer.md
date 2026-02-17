# Q005 解答：Proxy.isLocalHost() 對 "127.0.0.1" 返回 false

## 問題根因

`Proxy.getProxy()` 方法中調用 `isLocalHost()` 時傳入了錯誤的參數。傳入的是空字串 `host`（初始化為 ""），而不是從 URL 中解析出的實際 host。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/Proxy.java`

**問題代碼** (getProxy 方法):

```java
public static final java.net.Proxy getProxy(Context ctx, String url) {
    String host = "";
    if ((url != null) && !isLocalHost(host)) {  // Bug: 應該傳 url 或解析後的 host
        URI uri = URI.create(url);
        // ...
    }
    return java.net.Proxy.NO_PROXY;
}
```

## 問題分析

1. `host` 被初始化為空字串 `""`
2. 在解析 URL 之前就調用了 `isLocalHost(host)`
3. `isLocalHost("")` 返回 false（空字串不是 localhost）
4. 即使 URL 是 `http://127.0.0.1/`，也會進入代理邏輯

## 修復方案

應該先解析 URL 取得 host，然後再檢查：

```java
public static final java.net.Proxy getProxy(Context ctx, String url) {
    if (url == null) {
        return java.net.Proxy.NO_PROXY;
    }
    URI uri = URI.create(url);
    String host = uri.getHost();
    if (!isLocalHost(host)) {
        // 使用代理邏輯
    }
    return java.net.Proxy.NO_PROXY;
}
```

或者直接傳入 URL 讓 isLocalHost 解析（patch 的簡易修復）。

## 驗證命令

```bash
atest android.net.cts.ProxyTest#testIsLocalHost
```

## 學習要點

- 變量使用前確保已經正確賦值
- 注意變量初始化和實際使用的順序
- 代碼審查時關注變量的數據流
