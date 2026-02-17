# Q007: LocalServerSocket LISTEN_BACKLOG 值錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalServerSocketTest#testMultipleConnections

java.net.SocketException: Connection refused
    at android.net.cts.LocalServerSocketTest.testMultipleConnections(LocalServerSocketTest.java:65)
```

## 測試代碼片段

```java
@Test
public void testMultipleConnections() throws Exception {
    LocalServerSocket server = new LocalServerSocket("test_server");
    List<LocalSocket> clients = new ArrayList<>();
    
    // 嘗試建立多個連接
    for (int i = 0; i < 10; i++) {
        LocalSocket client = new LocalSocket();
        client.connect(new LocalSocketAddress("test_server"));
        clients.add(client);  // ← 第二個連接就失敗了
    }
    // ...
}
```

## 問題描述

`LocalServerSocket` 無法處理多個等待連接的客戶端。
即使只有少量客戶端嘗試連接，部分連接也會被拒絕。

這表明 `listen()` 的 backlog 參數設置過小。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：listen、backlog、連接佇列
