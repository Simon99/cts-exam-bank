# Q010: Attestation Version Check

## CTS Test
`android.keystore.cts.AttestationTest#testAttestationVersion`

## Failure Log
```
junit.framework.AssertionFailedError: 
Attestation version mismatch
Expected version: >= 3 (KeyMint)
Actual version: 2
Device should report KeyMint attestation version

at android.keystore.cts.AttestationTest.testAttestationVersion(AttestationTest.java:89)
```

## 現象描述
CTS 測試報告認證版本不正確。設備運行 Android 14，應該報告 KeyMint 版本（>= 3），
但認證顯示為舊版本 2。

## 提示
- KeyMaster 版本：1, 2, 3, 4
- KeyMint 版本：從 100 開始（但對外顯示為 3+）
- 問題出在版本號轉換邏輯

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// Attestation.java
private int parseAttestationVersion(int rawVersion) {
    // KeyMint versions start at 100 internally
    if (rawVersion >= 100) {
        return rawVersion - 100 + 2;  // LINE A: Convert to external version
    }
    return rawVersion;  // KeyMaster version
}
```

A) LINE A 的計算應該是 `rawVersion - 100 + 3`
B) 條件應該是 `rawVersion > 100`
C) KeyMint 版本不需要轉換
D) 應該使用常數而非魔術數字 100
