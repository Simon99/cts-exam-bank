# Q008: LocalSocketImpl Buffer Size 計算錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testAccessors

junit.framework.AssertionFailedError: 
Expected: 3998
Actual: 1999
    at android.net.cts.LocalSocketTest.testAccessors(LocalSocketTest.java:128)
```

## 測試代碼片段

```java
@Test
public void testAccessors() throws IOException {
    LocalSocket socket = new LocalSocket();
    // ...
    
    socket.setReceiveBufferSize(1999);
    assertEquals(1999 << 1, socket.getReceiveBufferSize());  // 期望 3998
    
    socket.setSendBufferSize(3998);
    assertEquals(3998 << 1, socket.getSendBufferSize());  // ← 這裡失敗，得到 1999
    // ...
}
```

## 問題描述

設置 Socket 的發送緩衝區大小後，讀取回來的值不正確。
根據 Linux 的行為，kernel 會將設置的值翻倍，
所以 `getSendBufferSize()` 應該返回設置值的兩倍。

但實際返回的值似乎沒有經過正確的處理。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：buffer size、SO_SNDBUF、getOption
