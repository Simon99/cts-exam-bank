# Q005: Proxy.isLocalHost() 對 "127.0.0.1" 返回 false

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.ProxyTest#testIsLocalHost

junit.framework.AssertionFailedError: 
Expected: true (should bypass proxy for localhost)
Actual: false
    at android.net.cts.ProxyTest.testIsLocalHost(ProxyTest.java:54)
```

## 測試代碼片段

```java
@Test
public void testIsLocalHost() throws Exception {
    // 測試 localhost 的各種形式
    assertTrue(isLocalHostAccessible("localhost"));    // ← 通過
    assertTrue(isLocalHostAccessible("127.0.0.1"));    // ← 失敗！
    assertTrue(isLocalHostAccessible("::1"));          // ← 通過
}

private boolean isLocalHostAccessible(String host) {
    // 使用反射調用 private 的 isLocalHost 方法
    java.net.Proxy proxy = Proxy.getProxy(mContext, "http://" + host + "/test");
    return proxy == java.net.Proxy.NO_PROXY;
}
```

## 問題描述

`Proxy.isLocalHost()` 應該識別所有本地地址並返回 true，但對於 "127.0.0.1" 返回了 false。

這導致對本地服務的請求會嘗試使用代理，可能導致連接失敗。

## 相關代碼結構

`Proxy.java` 中的 `isLocalHost()` 方法：
```java
private static final boolean isLocalHost(String host) {
    if (host == null) {
        return false;
    }
    try {
        if (host != null) {
            if (host.equalsIgnoreCase("localhost")) {
                return true;
            }
            if (InetAddresses.parseNumericAddress(host).isLoopbackAddress()) {
                return true;
            }
        }
    } catch (IllegalArgumentException iex) {
    }
    return false;
}
```

## 任務

1. 分析 `isLocalHost()` 方法的邏輯
2. 追蹤它如何被 `getProxy()` 調用
3. 找出為什麼 "127.0.0.1" 沒有被正確識別
4. 修復問題

## 提示

- 涉及文件數：2（Proxy.java，及其使用的 InetAddresses）
- 難度：Medium
- 關鍵字：isLocalHost、getProxy、localhost、127.0.0.1
