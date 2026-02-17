# SEC-M008: KeyChain getCertificateChain 返回順序錯誤

## CTS Test
`android.keychain.cts.KeyChainTest#testCertificateChainOrder`

## Failure Log
```
junit.framework.AssertionFailedError: Certificate chain order incorrect
Expected: [leaf, intermediate, root]
Actual: [root, intermediate, leaf]

at android.keychain.cts.KeyChainTest.testCertificateChainOrder(KeyChainTest.java:223)
```

## 現象描述
CTS 測試報告憑證鏈的順序不正確。
標準順序應該是從葉憑證開始到根憑證，
但實際返回的是相反的順序。

## 提示
- 憑證鏈的標準順序：[終端實體, 中繼 CA, 根 CA]
- 驗證憑證時從終端實體開始向上驗證
- 問題可能在於陣列的建構方式

## 選項

A) `getCertificateChain()` 返回前將陣列反轉了

B) 建構憑證鏈時使用了 LIFO (Stack) 結構

C) 憑證解析順序與加入列表順序相反

D) 返回時使用了 `Collections.reverse()` 錯誤地反轉了結果
