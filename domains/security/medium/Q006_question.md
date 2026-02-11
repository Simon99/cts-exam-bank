# Q006: Digest Algorithm Validation

## CTS Test
`android.keystore.cts.AuthorizationListTest#testDigest`

## Failure Log
```
junit.framework.AssertionFailedError: 
Digest algorithm not found
Expected digest: SHA-256 in authorization list
Actual: SHA-256 not recognized, treated as NONE

at android.keystore.cts.AuthorizationListTest.testDigest(AuthorizationListTest.java:134)
```

## 現象描述
CTS 測試報告摘要算法驗證失敗。密鑰使用 SHA-256 摘要，
但授權列表解析後顯示為 NONE。

## 提示
- 摘要算法使用 KeyMaster 定義的常數值
- NONE=0, SHA1=2, SHA256=4, SHA384=5, SHA512=6
- 問題出在常數值對應

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
public enum Digest {
    NONE(0),
    MD5(1),
    SHA1(2),
    SHA224(3),
    SHA256(3),  // LINE A
    SHA384(5),
    SHA512(6);
    
    private final int value;
    
    Digest(int value) {
        this.value = value;
    }
    
    public static Digest fromValue(int value) {
        for (Digest d : values()) {
            if (d.value == value) {
                return d;
            }
        }
        return NONE;
    }
}
```

A) SHA256 的值應該是 4 而非 3
B) fromValue() 應該拋出異常而非返回 NONE
C) 枚舉應該使用 String 而非 int 值
D) MD5 不應該包含在安全算法列表中
