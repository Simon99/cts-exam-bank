# Q003: Credentials getPid 返回錯誤值

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testLocalConnections

junit.framework.AssertionFailedError: expected to be non-zero but was 0
    at android.net.cts.LocalSocketTest.testLocalConnections(LocalSocketTest.java:84)
```

## 測試代碼片段

```java
@Test
public void testLocalConnections() throws IOException {
    // ... 建立連接 ...
    
    Credentials credent = clientSocket.getPeerCredentials();
    assertTrue(0 != credent.getPid());  // ← 這裡失敗，getPid() 返回 0
    
    // ...
}
```

## 問題描述

執行 CTS 測試時，`Credentials.getPid()` 返回 0，而不是預期的非零進程 ID。

根據 Unix Domain Socket 的規範，對端的 PID 應該通過 `SO_PEERCRED` 
socket 選項獲取，並且對於有效連接應該返回非零值。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：Credentials、getPid、返回值
