# Q004: LocalSocketAddress getNamespace 返回錯誤命名空間

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.LocalSocketAddressTest#testNamespace

junit.framework.AssertionFailedError: 
Expected: ABSTRACT
Actual: RESERVED
    at android.net.cts.LocalSocketAddressTest.testNamespace(LocalSocketAddressTest.java:45)
```

## 測試代碼片段

```java
@Test
public void testNamespace() {
    LocalSocketAddress addr = new LocalSocketAddress("test_socket");
    
    // 默認應該使用 ABSTRACT 命名空間
    assertEquals(LocalSocketAddress.Namespace.ABSTRACT, addr.getNamespace());  // ← 失敗
}
```

## 問題描述

創建 `LocalSocketAddress` 時如果只提供名稱（不指定命名空間），
應該默認使用 `ABSTRACT` 命名空間，但實際返回的是其他命名空間。

## 任務

1. 找出導致此錯誤的 bug
2. 修復該 bug
3. 驗證測試通過

## 提示

- 涉及文件數：1
- 難度：Easy
- 關鍵字：默認值、命名空間、構造函數
