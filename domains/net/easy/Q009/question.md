# Q009: LocalSocketImpl 超時設置使用錯誤常量

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testSetSoTimeout_readTimeout

junit.framework.AssertionFailedError: Timeout didn't occur within expected time
    at android.net.cts.LocalSocketTest.testSetSoTimeout_readTimeout(LocalSocketTest.java:186)
```

## 測試代碼片段

```java
@Test
public void testSetSoTimeout_readTimeout() throws Exception {
    // ...
    int timeoutMillis = 1000;
    clientSocket.setSoTimeout(timeoutMillis);

    Callable<Result> reader = () -> {
        try {
            clientSocket.getInputStream().read();  // 應該在 1 秒後超時
            return Result.noException("Did not block");
        } catch (IOException e) {
            return Result.exception(e);
        }
    };
    
    int allowedTime = timeoutMillis + 2000;  // 3 秒內應該完成
    Result result = runInSeparateThread(allowedTime, reader);
    // ← 測試超時，read() 沒有在預期時間內超時
}
```

## 問題描述

設置 Socket 讀取超時後，`read()` 操作沒有按預期超時。
超時設置似乎沒有正確生效。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：SO_TIMEOUT、SO_RCVTIMEO、setOption
