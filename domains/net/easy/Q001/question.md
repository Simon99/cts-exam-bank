# Q001: LocalSocket isConnected 狀態錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testLocalConnections

junit.framework.AssertionFailedError: expected true but was false
    at android.net.cts.LocalSocketTest.testLocalConnections(LocalSocketTest.java:74)
```

## 測試代碼片段

```java
@Test
public void testLocalConnections() throws IOException {
    String address = ADDRESS_PREFIX + "_testLocalConnections";
    LocalServerSocket localServerSocket = new LocalServerSocket(address);
    LocalSocket clientSocket = new LocalSocket();

    LocalSocketAddress locSockAddr = new LocalSocketAddress(address);
    assertFalse(clientSocket.isConnected());
    clientSocket.connect(locSockAddr);
    assertTrue(clientSocket.isConnected());  // ← 這裡失敗
    // ...
}
```

## 問題描述

執行 CTS 測試 `android.net.cts.LocalSocketTest#testLocalConnections` 時，
測試在驗證 `clientSocket.isConnected()` 返回 `true` 時失敗。

客戶端 Socket 已經成功調用 `connect()` 方法連接到服務器，
但 `isConnected()` 仍然返回 `false`。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：狀態標誌、connect
