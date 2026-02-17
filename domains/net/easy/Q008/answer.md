# Q008 解答：LocalSocketImpl Buffer Size 計算錯誤

## 問題根因

在 `LocalSocketImpl.java` 的 `getOption()` 方法中，
處理 `SO_SNDBUF` 選項時使用了錯誤的選項常量。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocketImpl.java`

**問題代碼**:

```java
public Object getOption(int optID) throws IOException {
    // ...
    switch (optID) {
        // ...
        case SocketOptions.SO_RCVBUF:
        case SocketOptions.SO_SNDBUF:
        case SocketOptions.SO_REUSEADDR:
            int osOpt = javaSoToOsOpt(optID);
            toReturn = Os.getsockoptInt(fd, OsConstants.SOL_SOCKET, 
                    OsConstants.SO_RCVBUF);  // Bug: 應該用 osOpt
            break;
        // ...
    }
}
```

## 修復方案

使用正確的選項常量：

```java
case SocketOptions.SO_RCVBUF:
case SocketOptions.SO_SNDBUF:
case SocketOptions.SO_REUSEADDR:
    int osOpt = javaSoToOsOpt(optID);
    toReturn = Os.getsockoptInt(fd, OsConstants.SOL_SOCKET, osOpt);  // ← 正確
    break;
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.LocalSocketTest#testAccessors
   ```

## 學習要點

- switch case 共享代碼時要確保變量正確使用
- `javaSoToOsOpt()` 已經計算了正確的 OS 選項，應該使用它
- 複製貼上容易導致硬編碼值沒有被替換
