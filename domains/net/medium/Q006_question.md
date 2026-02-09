# Q006: LocalServerSocket.accept() 後 getLocalSocketAddress() 返回 null

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalServerSocketTest#testAcceptedSocketAddress

junit.framework.AssertionFailedError: 
Expected: LocalSocketAddress with name "test_server"
Actual: null
    at android.net.cts.LocalServerSocketTest.testAcceptedSocketAddress(LocalServerSocketTest.java:89)
```

## 測試代碼片段

```java
@Test
public void testAcceptedSocketAddress() throws Exception {
    String socketName = "test_server";
    LocalServerSocket server = new LocalServerSocket(socketName);
    
    // 驗證 server 的地址
    LocalSocketAddress serverAddr = server.getLocalSocketAddress();
    assertEquals(socketName, serverAddr.getName());  // ← 通過
    
    // 客戶端連接
    LocalSocket client = new LocalSocket();
    client.connect(new LocalSocketAddress(socketName));
    
    // 接受連接
    LocalSocket accepted = server.accept();
    
    // 驗證 accepted socket 的本地地址
    LocalSocketAddress acceptedAddr = accepted.getLocalSocketAddress();
    assertNotNull(acceptedAddr);  // ← 失敗！返回 null
}
```

## 問題描述

通過 `LocalServerSocket.accept()` 獲得的 socket，調用 `getLocalSocketAddress()` 返回 null。

按照設計，accepted socket 應該繼承 server socket 的本地地址。

## 相關代碼結構

```java
// LocalServerSocket.accept()
public LocalSocket accept() throws IOException {
    LocalSocketImpl acceptedImpl = new LocalSocketImpl();
    impl.accept(acceptedImpl);
    return LocalSocket.createLocalSocketForAccept(acceptedImpl);
}

// LocalSocket.getLocalSocketAddress()
public LocalSocketAddress getLocalSocketAddress() {
    return localAddress;  // 這個值沒有被設置
}
```

## 任務

1. 追蹤 `accept()` 的完整流程
2. 找出 `localAddress` 為什麼沒有被正確設置
3. 修復問題

## 提示

- 涉及文件數：2（LocalServerSocket.java, LocalSocket.java）
- 難度：Medium
- 關鍵字：accept、createLocalSocketForAccept、localAddress
