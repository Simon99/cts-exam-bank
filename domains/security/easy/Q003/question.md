# Q003: Key Algorithm Validation

## CTS Test
`android.keystore.cts.AuthorizationListTest#testAlgorithm`

## Failure Log
```
junit.framework.AssertionFailedError: 
Expected algorithm: EC
Actual algorithm: RSA
Authorization list contains wrong algorithm identifier

at android.keystore.cts.AuthorizationListTest.testAlgorithm(AuthorizationListTest.java:89)
```

## 現象描述
CTS 測試報告授權列表中的算法識別碼不正確。生成 EC 密鑰時，授權列表卻顯示為 RSA 算法。

## 提示
- KeyMaster 算法常數：RSA=1, EC=3, AES=32, HMAC=128
- 授權列表從認證擴展中解析
- 問題出在算法常數對應

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
public static final int ALGORITHM_RSA = 1;
public static final int ALGORITHM_EC = 3;
public static final int ALGORITHM_AES = 32;

public Algorithm getAlgorithm(int algorithmTag) {
    switch (algorithmTag) {
        case ALGORITHM_RSA:
            return Algorithm.RSA;
        case ALGORITHM_AES:
            return Algorithm.AES;
        case 1:  // LINE A
            return Algorithm.EC;
        default:
            return Algorithm.UNKNOWN;
    }
}
```

A) ALGORITHM_EC 常數值定義錯誤
B) LINE A 應該使用 ALGORITHM_EC 常數而非硬編碼的 1
C) 缺少 HMAC 的處理 case
D) default 應該拋出異常
