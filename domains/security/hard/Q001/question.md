# Q001: Certificate Pinning Chain Validation

## CTS Test
`android.security.cts.NetworkSecurityConfigTest#testCertificatePinningWithChain`

## Failure Log
```
java.security.cert.CertificateException: Pin verification failed
Certificate chain does not match any configured pin

at android.security.net.config.NetworkSecurityTrustManager.checkServerTrusted(NetworkSecurityTrustManager.java:142)
at android.security.net.config.NetworkSecurityConfigTest.testCertificatePinningWithChain(NetworkSecurityConfigTest.java:287)

Caused by: java.lang.SecurityException: No matching pin found in chain
    at android.security.net.config.PinSet.validateChain(PinSet.java:98)
```

## 現象描述
CTS 測試報告憑證釘選驗證失敗。系統聲稱憑證鏈中沒有任何憑證符合配置的 PIN，但實際上 Root CA 的 PIN 是正確配置的。測試在驗證中間 CA 簽發的伺服器憑證時失敗。

## 背景知識
憑證釘選 (Certificate Pinning) 要求驗證憑證鏈中至少有一個憑證的公鑰指紋符合預設的 PIN。鏈的結構通常是：
- `chain[0]` = 伺服器憑證 (Leaf)
- `chain[1]` = 中間 CA (Intermediate)
- `chain[2]` = 根 CA (Root)

## 提示
- 問題涉及 `PinSet.java` 和 `NetworkSecurityTrustManager.java` 兩個檔案的交互
- 注意 `PinSet.validateChain()` 如何處理憑證鏈
- 注意 `NetworkSecurityTrustManager` 如何傳遞憑證鏈給 PinSet

## 問題
根據以下兩個檔案的程式碼片段，哪個組合最可能導致此 CTS 失敗？

**檔案 1: PinSet.java**
```java
public class PinSet {
    private final Set<Pin> mPins;
    private final boolean mIncludeChain;  // 是否驗證整條鏈
    
    public boolean validateChain(X509Certificate[] chain) {
        if (chain == null || chain.length == 0) {
            return false;
        }
        
        int validateCount = mIncludeChain ? chain.length : 1;  // LINE P1
        
        for (int i = 0; i <= validateCount; i++) {  // LINE P2
            String certPin = computePin(chain[i]);
            if (mPins.contains(new Pin(certPin))) {
                return true;
            }
        }
        return false;
    }
    
    private String computePin(X509Certificate cert) {
        return Base64.encode(sha256(cert.getPublicKey().getEncoded()));
    }
}
```

**檔案 2: NetworkSecurityTrustManager.java**
```java
public class NetworkSecurityTrustManager {
    private final PinSet mPinSet;
    private final X509TrustManager mDelegate;
    
    @Override
    public void checkServerTrusted(X509Certificate[] certs, String authType) {
        // 先由底層 TrustManager 驗證憑證鏈有效性
        X509Certificate[] validatedChain = mDelegate.checkServerTrusted(certs, authType);
        
        // 再驗證釘選
        if (mPinSet != null && mPinSet.isEnabled()) {
            X509Certificate[] chainToValidate = Arrays.copyOf(certs, certs.length - 1);  // LINE T1
            if (!mPinSet.validateChain(chainToValidate)) {  // LINE T2
                throw new CertificateException("Pin verification failed");
            }
        }
    }
}
```

A) LINE P1 計算錯誤：當 `mIncludeChain=true` 時應該用 `chain.length - 1`
B) LINE P2 迴圈條件錯誤：`i <= validateCount` 應該是 `i < validateCount`
C) LINE T1 截斷錯誤：移除了根 CA，但釘選可能配置在根 CA 上
D) 問題出在 LINE P2 和 LINE T1 的組合：迴圈越界加上鏈被截斷

