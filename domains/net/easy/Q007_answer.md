# Q007 解答：LocalServerSocket LISTEN_BACKLOG 值錯誤

## 問題根因

在 `LocalServerSocket.java` 中，`LISTEN_BACKLOG` 常量被設置為過小的值（1），
導致連接佇列無法容納多個等待的連接。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalServerSocket.java`

**問題代碼**:

```java
public class LocalServerSocket implements Closeable {
    private final LocalSocketImpl impl;
    private final LocalSocketAddress localAddress;

    /** 50 seems a bit much, but it's what was here */
    private static final int LISTEN_BACKLOG = 1;  // Bug: 應該是 50
    
    // ...
}
```

## 修復方案

將 `LISTEN_BACKLOG` 恢復為合理的值：

```java
private static final int LISTEN_BACKLOG = 50;  // ← 正確：允許足夠的等待連接
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.LocalServerSocketTest#testMultipleConnections
   ```

## 學習要點

- `listen()` 的 backlog 參數定義等待連接的最大數量
- 過小的 backlog 會導致連接被拒絕
- 註釋說明了原始意圖：50 已經足夠處理常見情況
