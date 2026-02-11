# SEC-H002: Verified Boot Hash 比對時序攻擊漏洞

## CTS Test
`android.keystore.cts.RootOfTrustTest#testVerifiedBootHashComparison`

## Failure Log
```
junit.framework.AssertionFailedError: Hash comparison security test failed
Test detected timing difference in hash comparison.
Comparison time varied based on matching prefix length.

This indicates vulnerable to timing attacks.
at android.keystore.cts.RootOfTrustTest.testVerifiedBootHashComparison(RootOfTrustTest.java:198)
```

## 相關測試上下文
```java
// 測試雜湊比對是否為常數時間
long[] times = measureComparisonTimes(correctHash, varyingPrefixHashes);
assertConstantTime(times);  // 所有比較應該花費相同時間
```

## 現象描述
CTS 測試發現 verified boot hash 的比對時間會因為匹配的前綴長度而變化。
這表示使用了非常數時間的比較方法，可能被時序攻擊利用。

## 提示
- 時序攻擊可以透過測量操作時間推斷秘密資訊
- 標準的陣列比較在發現不匹配時會提早返回
- 安全的比較應該總是檢查所有位元組

## 選項

A) 使用 `Arrays.equals()` 進行比較，它會在發現不匹配時提早返回

B) 比較函數中使用了 `||` 短路運算，跳過後續比較

C) 使用了 `MessageDigest.isEqual()` 但實作有問題

D) 比較時使用了 String 的 `equals()` 方法
