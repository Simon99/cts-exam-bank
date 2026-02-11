# SEC-E003: Algorithm 驗證缺少 EC 算法

## CTS Test
`android.keystore.cts.AuthorizationListTest#testEcAlgorithm`

## Failure Log
```
junit.framework.AssertionFailedError: EC algorithm not recognized
Expected: KM_ALGORITHM_EC (3)
Actual: null (algorithm not found)

at android.keystore.cts.AuthorizationListTest.testEcAlgorithm(AuthorizationListTest.java:98)
```

## 現象描述
CTS 測試報告在驗證 Key Attestation 的 AuthorizationList 時，
EC (Elliptic Curve) 算法無法被識別，即使密鑰確實是用 EC 算法生成的。

## 提示
- AuthorizationList 包含密鑰的各種屬性
- 常見算法：RSA(1), EC(3), AES(32), HMAC(128)
- 問題可能在於算法識別的 switch/case 語句

## 選項

A) Algorithm 常數 `KM_ALGORITHM_EC` 的值定義錯誤

B) 解析算法時的 switch 語句中缺少 `case KM_ALGORITHM_EC` 分支

C) EC 算法解析時使用了錯誤的 TAG 值

D) `getAlgorithm()` 方法沒有處理 EC 類型，直接返回 null
