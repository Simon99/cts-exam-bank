# Q002 解答：LocalSocket 文件描述符傳遞後對端收到 null

## 問題根因

`LocalSocketImpl.setFileDescriptorsForSend()` 方法中，錯誤地將 `outboundFileDescriptors` 設為 `null` 而不是傳入的 `fds` 參數。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocketImpl.java`

**問題代碼** (setFileDescriptorsForSend 方法):

```java
public void setFileDescriptorsForSend(FileDescriptor[] fds) {
    synchronized(writeMonitor) {
        outboundFileDescriptors = null;  // Bug: 應該是 fds
    }
}
```

## 修復方案

```java
public void setFileDescriptorsForSend(FileDescriptor[] fds) {
    synchronized(writeMonitor) {
        outboundFileDescriptors = fds;  // 正確：賦值傳入的 fds
    }
}
```

## 呼叫鏈分析

```
LocalSocket.setFileDescriptorsForSend(fds)
    └── LocalSocketImpl.setFileDescriptorsForSend(fds)
            └── outboundFileDescriptors = fds  ← Bug 在這裡
            
LocalSocket.getOutputStream().write(data)
    └── LocalSocketImpl.SocketOutputStream.write()
            └── writeba_native(data, fd)
                    └── sendmsg() with SCM_RIGHTS (outboundFileDescriptors)
                            └── 因為 outboundFileDescriptors 是 null，不發送 FD

服務端：
LocalSocketImpl.SocketInputStream.read()
    └── readba_native()
            └── recvmsg() with SCM_RIGHTS
                    └── 填充 inboundFileDescriptors (但沒收到任何 FD)

LocalSocket.getAncillaryFileDescriptors()
    └── return inboundFileDescriptors (null)
```

## Unix Domain Socket FD 傳遞機制

FD 傳遞使用 `sendmsg()`/`recvmsg()` 的 ancillary data：
- 發送端：將 FD 放入 `struct cmsghdr` (cmsg_type = SCM_RIGHTS)
- 接收端：從 ancillary data 中提取 FD

Native 代碼會檢查 `outboundFileDescriptors`：
```c
if (outboundFileDescriptors != NULL) {
    // 構建 SCM_RIGHTS 消息
}
```

因為 Java 層設為 null，native 不會發送任何 FD。

## 驗證命令

```bash
atest android.net.cts.LocalSocketTest#testFileDescriptorPassing
```

## 學習要點

- Unix domain socket 可以傳遞文件描述符
- SCM_RIGHTS 是傳遞 FD 的標準機制
- 賦值時確保使用正確的變量
