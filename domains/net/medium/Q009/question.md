# Q009: LocalSocket.setSoTimeout() 設置的超時不生效

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testReadTimeout

java.net.SocketTimeoutException expected but not thrown
Test timed out after 10000 ms
    at android.net.cts.LocalSocketTest.testReadTimeout(LocalSocketTest.java:156)
```

## 測試代碼片段

```java
@Test(timeout = 10000)
public void testReadTimeout() throws Exception {
    LocalServerSocket server = new LocalServerSocket("timeout_test");
    LocalSocket client = new LocalSocket();
    client.connect(new LocalSocketAddress("timeout_test"));
    
    LocalSocket accepted = server.accept();
    
    // 設置 500ms 讀取超時
    client.setSoTimeout(500);
    assertEquals(500, client.getSoTimeout());  // ← 通過
    
    // 嘗試讀取（沒有數據）- 應該 500ms 後拋出 SocketTimeoutException
    try {
        client.getInputStream().read();  // ← 這裡應該超時，但一直阻塞
        fail("Expected SocketTimeoutException");
    } catch (SocketTimeoutException e) {
        // 預期行為
    }
}
```

## 問題描述

`LocalSocket.setSoTimeout()` 設置的超時值可以正確讀回，但實際的 `read()` 操作沒有遵守超時設置，一直阻塞。

## 相關代碼結構

`LocalSocket.java`:
```java
public void setSoTimeout(int n) throws IOException {
    impl.setOption(SocketOptions.SO_TIMEOUT, Integer.valueOf(n));
}
```

`LocalSocketImpl.java`:
```java
public void setOption(int optID, Object value) throws IOException {
    // ...
    switch (optID) {
        case SocketOptions.SO_TIMEOUT:
            StructTimeval timeval = StructTimeval.fromMillis(intValue);
            Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, OsConstants.SO_RCVTIMEO, timeval);
            Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, OsConstants.SO_SNDTIMEO, timeval);
            break;
        // ...
    }
}
```

## 任務

1. 追蹤 `setSoTimeout()` 的實現
2. 檢查 `setOption()` 中 SO_TIMEOUT 的處理
3. 找出為什麼超時沒有生效
4. 修復問題

## 提示

- 涉及文件數：2（LocalSocket.java, LocalSocketImpl.java）
- 難度：Medium
- 關鍵字：setSoTimeout、setOption、SO_RCVTIMEO、SO_SNDTIMEO
