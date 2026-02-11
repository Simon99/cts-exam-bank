# Q007: Device Locked State

## CTS Test
`android.keystore.cts.RootOfTrustTest#testDeviceLocked`

## Failure Log
```
junit.framework.AssertionFailedError: 
Device locked state mismatch
Expected: LOCKED (device booted in locked state)
Actual: UNLOCKED
Root of trust reports incorrect lock state

at android.keystore.cts.RootOfTrustTest.testDeviceLocked(RootOfTrustTest.java:67)
```

## 現象描述
CTS 測試報告設備鎖定狀態不正確。設備應該在鎖定狀態啟動，
但信任根報告顯示為未鎖定。

## 提示
- deviceLocked 在 RootOfTrust 中是一個布林值
- 值為 true 表示設備啟動時 bootloader 是鎖定的
- 問題出在布林值解析

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// RootOfTrust.java
public class RootOfTrust {
    private boolean deviceLocked;
    
    public void parse(ASN1Sequence sequence) {
        // ... verifiedBootKey parsing ...
        
        ASN1Boolean lockedValue = (ASN1Boolean) sequence.getObjectAt(1);
        this.deviceLocked = !lockedValue.isTrue();  // LINE A
        
        // ... rest of parsing ...
    }
    
    public boolean isDeviceLocked() {
        return deviceLocked;
    }
}
```

A) getObjectAt(1) 應該是 getObjectAt(0)
B) LINE A 不應該有 `!` 取反操作
C) 應該使用 ASN1Integer 而非 ASN1Boolean
D) 應該先檢查 lockedValue 是否為 null
