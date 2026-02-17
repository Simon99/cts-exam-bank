# Q008: LocalSocket 輸出流寫入後數據截斷

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testLargeDataTransfer

junit.framework.AssertionFailedError: 
Data corruption detected
Expected length: 65536
Actual length: 65535
    at android.net.cts.LocalSocketTest.testLargeDataTransfer(LocalSocketTest.java:267)
```

## 測試代碼片段

```java
@Test
public void testLargeDataTransfer() throws Exception {
    LocalServerSocket server = new LocalServerSocket("large_data_test");
    LocalSocket client = new LocalSocket();
    client.connect(new LocalSocketAddress("large_data_test"));
    LocalSocket serverSide = server.accept();
    
    // 準備大量數據
    byte[] sendData = new byte[65536];  // 64KB
    new Random().nextBytes(sendData);
    
    // 發送數據
    OutputStream out = client.getOutputStream();
    out.write(sendData);
    out.flush();
    
    // 接收數據
    InputStream in = serverSide.getInputStream();
    ByteArrayOutputStream received = new ByteArrayOutputStream();
    byte[] buffer = new byte[4096];
    int totalRead = 0;
    while (totalRead < sendData.length) {
        int n = in.read(buffer);
        if (n < 0) break;
        received.write(buffer, 0, n);
        totalRead += n;
    }
    
    // 驗證
    byte[] receivedData = received.toByteArray();
    assertEquals(sendData.length, receivedData.length);  // ← 失敗！少了 1 byte
    assertArrayEquals(sendData, receivedData);
}
```

## 問題描述

大數據傳輸時，接收端收到的數據比發送端少了 1 字節。這是一個 off-by-one 錯誤。

## 相關代碼結構

`LocalSocketImpl.java` 中的 SocketOutputStream：
```java
class SocketOutputStream extends OutputStream {
    @Override
    public void write(byte[] b, int off, int len) throws IOException {
        synchronized (writeMonitor) {
            FileDescriptor myFd = fd;
            if (myFd == null) throw new IOException("socket closed");
            
            if (off < 0 || len < 0 || (off + len) > b.length) {
                throw new ArrayIndexOutOfBoundsException();
            }
            writeba_native(b, off, len, myFd);
        }
    }
}

// Native 方法
private native void writeba_native(byte[] b, int off, int len, FileDescriptor fd);
```

涉及 Java 層的邊界檢查和 native 層的實際寫入。

## 任務

1. 分析 `write(byte[], int, int)` 的實現
2. 檢查邊界條件
3. 追蹤到 native 方法的參數傳遞
4. 找出數據截斷的原因

## 提示

- 涉及文件數：3（LocalSocketImpl.java, LocalSocket.java, native 代碼）
- 難度：Hard
- 關鍵字：write、writeba_native、len、off-by-one
- 呼叫鏈：OutputStream.write() → writeba_native() → 系統調用
