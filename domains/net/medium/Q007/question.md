# Q007: Credentials.getPid() 返回錯誤的值

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testPeerCredentials

junit.framework.AssertionFailedError: 
Expected PID > 0
Actual: 0
    at android.net.cts.LocalSocketTest.testPeerCredentials(LocalSocketTest.java:198)
```

## 測試代碼片段

```java
@Test
public void testPeerCredentials() throws Exception {
    LocalServerSocket server = new LocalServerSocket("cred_test");
    LocalSocket client = new LocalSocket();
    client.connect(new LocalSocketAddress("cred_test"));
    
    LocalSocket serverSide = server.accept();
    
    // 獲取對端憑證
    Credentials creds = serverSide.getPeerCredentials();
    
    // 驗證憑證有效
    assertTrue("PID should be positive", creds.getPid() > 0);  // ← 失敗
    assertTrue("UID should be non-negative", creds.getUid() >= 0);  // ← 通過
    assertTrue("GID should be non-negative", creds.getGid() >= 0);  // ← 通過
}
```

## 問題描述

通過 `LocalSocket.getPeerCredentials()` 獲取的憑證中，`getPid()` 返回 0，但 UID 和 GID 是正確的。

Unix domain socket 的 `SO_PEERCRED` 應該能正確獲取對端進程的 PID、UID、GID。

## 相關代碼結構

`Credentials.java`：
```java
public class Credentials {
    private final int pid;
    private final int uid;
    private final int gid;

    public Credentials(int pid, int uid, int gid) {
        this.pid = pid;
        this.uid = uid;
        this.gid = gid;
    }

    public int getPid() { return pid; }
    public int getUid() { return uid; }
    public int getGid() { return gid; }
}
```

`LocalSocketImpl.java` (native 方法)：
```java
public Credentials getPeerCredentials() throws IOException {
    return getPeerCredentials_native(fd);
}
```

## 任務

1. 檢查 `Credentials` 類的構造函數參數順序
2. 追蹤 native 方法是如何創建 Credentials 對象的
3. 找出參數順序錯誤的位置
4. 修復問題

## 提示

- 涉及文件數：2（Credentials.java, LocalSocketImpl.java）
- 難度：Medium
- 關鍵字：Credentials、getPeerCredentials、pid、uid、gid、參數順序
