# Q002: LocalSocket isBound 狀態錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketTest#testAccessors

junit.framework.AssertionFailedError: expected true but was false
    at android.net.cts.LocalSocketTest.testAccessors(LocalSocketTest.java:115)
```

## 測試代碼片段

```java
@Test
public void testAccessors() throws IOException {
    String address = ADDRESS_PREFIX + "_testAccessors";
    LocalSocket socket = new LocalSocket();
    LocalSocketAddress addr = new LocalSocketAddress(address);

    assertFalse(socket.isBound());
    socket.bind(addr);
    assertTrue(socket.isBound());  // ← 這裡失敗
    assertEquals(addr, socket.getLocalSocketAddress());
    // ...
}
```

## 問題描述

執行 CTS 測試 `android.net.cts.LocalSocketTest#testAccessors` 時，
測試在驗證 `socket.isBound()` 返回 `true` 時失敗。

Socket 已經成功調用 `bind()` 方法綁定到地址，
但 `isBound()` 仍然返回 `false`。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：狀態標誌、bind
