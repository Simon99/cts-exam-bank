# Q006 解答：LocalServerSocket.accept() 後 getLocalSocketAddress() 返回 null

## 問題根因

`LocalServerSocket.accept()` 方法中，`impl.accept(acceptedImpl)` 這行代碼被錯誤地註解掉或移除。

這導致 acceptedImpl 沒有正確初始化，FileDescriptor 為 null，後續操作都會失敗。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalServerSocket.java`

**問題代碼** (accept 方法):

```java
public LocalSocket accept() throws IOException {
    LocalSocketImpl acceptedImpl = new LocalSocketImpl();
    // impl.accept(acceptedImpl);  // Bug: 被註解掉，沒有實際執行 accept
    return LocalSocket.createLocalSocketForAccept(acceptedImpl);
}
```

## 修復方案

取消註解，恢復正確的調用：

```java
public LocalSocket accept() throws IOException {
    LocalSocketImpl acceptedImpl = new LocalSocketImpl();
    impl.accept(acceptedImpl);  // 正確：執行系統調用獲取連接
    return LocalSocket.createLocalSocketForAccept(acceptedImpl);
}
```

## 問題分析

`impl.accept()` 做了以下事情：
1. 調用底層 `Os.accept()` 獲取新連接的 file descriptor
2. 將 fd 設置到 `acceptedImpl` 中
3. 設置 `mFdCreatedInternally = true`

沒有這個調用：
- `acceptedImpl.fd` 為 null
- `checkConnected()` 會失敗
- `getLocalSocketAddress()` 返回 null

## 驗證命令

```bash
atest android.net.cts.LocalServerSocketTest#testAcceptedSocketAddress
```

## 學習要點

- 代碼審查時注意被註解的關鍵代碼
- 理解 server socket accept 的工作原理
- 測試應該驗證完整的功能路徑
