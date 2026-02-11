# SEC-M008 Answer: KeyChain getCertificateChain 返回順序錯誤

## 正確答案
**D) 返回時使用了 `Collections.reverse()` 錯誤地反轉了結果**

## 問題根因
在 `KeyChain.java` 的 `getCertificateChain()` 方法中，
在返回前錯誤地調用了 `Collections.reverse()` 將憑證鏈反轉，
導致順序與標準相反。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
public static X509Certificate[] getCertificateChain(Context context, String alias)
        throws KeyChainException, InterruptedException {
    List<X509Certificate> certs = parseCertificates(response);
    Collections.reverse(certs);  // BUG: 不該反轉
    return certs.toArray(new X509Certificate[0]);
}

// 正確的代碼
public static X509Certificate[] getCertificateChain(Context context, String alias)
        throws KeyChainException, InterruptedException {
    List<X509Certificate> certs = parseCertificates(response);
    return certs.toArray(new X509Certificate[0]);
}
```

## 為什麼其他選項不對

**A)** 「返回前反轉」和 D 描述的是同一件事，但 D 更精確指出使用了什麼方法。

**B)** 使用 Stack 會有 push/pop 行為，但不會是明確的 reverse 操作。

**C)** 解析順序相反可能導致問題，但從「完全相反」的結果看，更像是顯式反轉。

## 相關知識
- X.509 憑證鏈從終端實體（葉）開始，以根 CA 結束
- TLS/SSL 握手時會傳送整個憑證鏈
- 錯誤的順序可能導致驗證失敗

## 難度說明
**Medium** - 需要理解憑證鏈的標準順序和 API 預期。
