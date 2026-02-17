# Q002: LocalSocket 文件描述符傳遞後對端收到 null

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testFileDescriptorPassing

junit.framework.AssertionFailedError: 
Expected: FileDescriptor array with 1 element
Actual: null
    at android.net.cts.LocalSocketTest.testFileDescriptorPassing(LocalSocketTest.java:234)
```

## 測試代碼片段

```java
@Test
public void testFileDescriptorPassing() throws Exception {
    LocalServerSocket server = new LocalServerSocket("fd_test");
    LocalSocket client = new LocalSocket();
    client.connect(new LocalSocketAddress("fd_test"));
    LocalSocket serverSide = server.accept();
    
    // 創建一個文件並獲取其 FD
    File tempFile = File.createTempFile("test", ".txt");
    FileInputStream fis = new FileInputStream(tempFile);
    FileDescriptor fd = fis.getFD();
    
    // 客戶端發送 FD
    client.setFileDescriptorsForSend(new FileDescriptor[] { fd });
    client.getOutputStream().write("hello".getBytes());  // 必須有數據一起發送
    
    // 服務端接收
    byte[] buf = new byte[5];
    serverSide.getInputStream().read(buf);
    assertEquals("hello", new String(buf));  // ← 通過
    
    // 服務端獲取 FD
    FileDescriptor[] receivedFds = serverSide.getAncillaryFileDescriptors();
    assertNotNull(receivedFds);  // ← 失敗！返回 null
    assertEquals(1, receivedFds.length);
}
```

## 問題描述

使用 Unix domain socket 傳遞文件描述符失敗：
1. `setFileDescriptorsForSend()` 設置 FD
2. 隨數據一起發送
3. 對端 `getAncillaryFileDescriptors()` 返回 null

這涉及到 LocalSocket、LocalSocketImpl、以及底層 native 代碼的交互。

## 相關代碼結構

```java
// LocalSocket.java
public void setFileDescriptorsForSend(FileDescriptor[] fds) {
    impl.setFileDescriptorsForSend(fds);
}

// LocalSocketImpl.java
public void setFileDescriptorsForSend(FileDescriptor[] fds) {
    synchronized(writeMonitor) {
        outboundFileDescriptors = fds;
    }
}

public FileDescriptor[] getAncillaryFileDescriptors() throws IOException {
    synchronized(readMonitor) {
        FileDescriptor[] result = inboundFileDescriptors;
        inboundFileDescriptors = null;
        return result;
    }
}
```

## 任務

1. 追蹤 FD 發送的完整流程
2. 檢查 `LocalSocketImpl` 如何設置 `outboundFileDescriptors`
3. 檢查 native `read` 方法如何填充 `inboundFileDescriptors`
4. 找出為什麼接收端收不到 FD

## 提示

- 涉及文件數：3（LocalSocket.java, LocalSocketImpl.java, native 層面）
- 難度：Hard
- 關鍵字：setFileDescriptorsForSend、getAncillaryFileDescriptors、SCM_RIGHTS
- 呼叫鏈：LocalSocket → LocalSocketImpl → native read/write
