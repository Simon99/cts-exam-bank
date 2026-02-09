# Q002: LocalSocket 讀取操作拋出 ArrayIndexOutOfBoundsException

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testLocalSocketReadWithOffset

java.lang.ArrayIndexOutOfBoundsException
    at android.net.LocalSocketImpl$SocketInputStream.read(LocalSocketImpl.java:98)
    at android.net.cts.LocalSocketTest.testLocalSocketReadWithOffset(LocalSocketTest.java:134)
```

## 測試代碼片段

```java
@Test
public void testLocalSocketReadWithOffset() throws Exception {
    LocalServerSocket server = new LocalServerSocket("test_offset");
    LocalSocket client = new LocalSocket();
    client.connect(new LocalSocketAddress("test_offset"));
    
    LocalSocket serverClient = server.accept();
    
    // 發送數據
    serverClient.getOutputStream().write("Hello".getBytes());
    
    // 使用 offset 讀取
    byte[] buffer = new byte[10];
    int offset = 3;
    int length = 5;
    InputStream is = client.getInputStream();
    int bytesRead = is.read(buffer, offset, length);  // ← ArrayIndexOutOfBoundsException
    
    assertEquals(5, bytesRead);
    assertEquals("Hello", new String(buffer, offset, bytesRead));
}
```

## 問題描述

使用帶 offset 的 `read(byte[], int, int)` 方法讀取數據時，拋出 `ArrayIndexOutOfBoundsException`。

追蹤發現：
- `LocalSocket.getInputStream()` 返回 `LocalSocketImpl.SocketInputStream`
- `SocketInputStream.read(byte[], int, int)` 內部調用 native 方法
- 邊界檢查的條件可能寫錯了

## 任務

1. 找到 `LocalSocketImpl.SocketInputStream.read()` 方法
2. 分析邊界檢查邏輯
3. 修復錯誤的邊界判斷

## 提示

- 涉及文件數：2（LocalSocket.java, LocalSocketImpl.java）
- 難度：Medium
- 關鍵字：read、offset、ArrayIndexOutOfBoundsException、邊界檢查
