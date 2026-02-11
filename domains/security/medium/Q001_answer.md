# Q001 Answer: Certificate Attestation Loading

## 正確答案
**B) extensionValue 是 OCTET STRING 包裝，需要先解包再解析**

## 問題根因
`X509Certificate.getExtensionValue()` 返回的是 DER 編碼的 OCTET STRING，
其中包含了實際的擴展值。直接將這個 OCTET STRING 解析為 ASN1Sequence 會失敗，
因為最外層是 OCTET STRING 而不是 SEQUENCE。

需要先將 OCTET STRING 解包，提取其中的內容，再解析為 ASN1Sequence。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
ASN1Sequence sequence = (ASN1Sequence) ASN1Primitive.fromByteArray(extensionValue);

// 正確的代碼
ASN1OctetString octetString = (ASN1OctetString) ASN1Primitive.fromByteArray(extensionValue);
byte[] extensionContent = octetString.getOctets();
ASN1Sequence sequence = (ASN1Sequence) ASN1Primitive.fromByteArray(extensionContent);
```

## 選項分析
- **A) 錯誤** - ASN1Primitive.fromByteArray() 功能上是正確的
- **B) 正確** - 擴展值需要先解除 OCTET STRING 包裝
- **C) 錯誤** - 類型轉換失敗會拋出異常，不會返回 null
- **D) 錯誤** - OID 正確，否則 getExtensionValue 會返回 null

## 相關知識
- X.509 擴展結構：OID + critical flag + OCTET STRING(value)
- OCTET STRING 是 ASN.1 的二進制資料容器
- 這是 X.509 標準的雙重編碼設計，確保擴展值的透明傳輸

## 難度說明
**Medium** - 需要理解 X.509 擴展的雙層結構，不是直觀可見的問題。
