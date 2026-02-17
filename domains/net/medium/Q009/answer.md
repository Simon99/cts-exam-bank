# Q009 解答：LocalSocket.setSoTimeout() 設置的超時不生效

## 問題根因

`LocalSocketImpl.setOption()` 處理 `SO_TIMEOUT` 時，只設置了 `SO_SNDTIMEO`（發送超時），沒有設置 `SO_RCVTIMEO`（接收超時）。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocketImpl.java`

**問題代碼** (setOption 方法的 SO_TIMEOUT case):

```java
case SocketOptions.SO_TIMEOUT:
    // Bug: 只設置了 SO_SNDTIMEO
    StructTimeval timeval = StructTimeval.fromMillis(intValue);
    Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, OsConstants.SO_SNDTIMEO, timeval);
    break;
```

## 修復方案

```java
case SocketOptions.SO_TIMEOUT:
    StructTimeval timeval = StructTimeval.fromMillis(intValue);
    // 設置接收超時 - 用於 read() 操作
    Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, OsConstants.SO_RCVTIMEO, timeval);
    // 設置發送超時 - 用於 write() 操作
    Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, OsConstants.SO_SNDTIMEO, timeval);
    break;
```

## Socket 超時說明

| 選項 | 用途 | 影響的操作 |
|-----|------|----------|
| SO_RCVTIMEO | 接收超時 | read(), recv() |
| SO_SNDTIMEO | 發送超時 | write(), send() |

`setSoTimeout()` 的語義是設置 I/O 操作的超時，應該同時設置兩者。

## 驗證命令

```bash
atest android.net.cts.LocalSocketTest#testReadTimeout
```

## 學習要點

- `SO_TIMEOUT` 需要同時設置收發超時
- 測試時要驗證實際行為，不只是 getter/setter
- 理解底層 socket 選項的語義
