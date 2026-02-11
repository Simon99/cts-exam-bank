# SEC-M007 Answer: KeyChain getPrivateKey 異常處理錯誤

## 正確答案
**A) catch 區塊中將 RemoteException 包裝成 RuntimeException 而非 KeyChainException**

## 問題根因
在 `KeyChain.java` 的 `getPrivateKey()` 方法中，
catch RemoteException 時錯誤地將其包裝成 RuntimeException，
而非 API 規定的 KeyChainException。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
public static PrivateKey getPrivateKey(Context context, String alias)
        throws KeyChainException, InterruptedException {
    try {
        // ... 服務呼叫 ...
    } catch (RemoteException e) {
        throw new RuntimeException(e);  // BUG: 應該是 KeyChainException
    }
}

// 正確的代碼
public static PrivateKey getPrivateKey(Context context, String alias)
        throws KeyChainException, InterruptedException {
    try {
        // ... 服務呼叫 ...
    } catch (RemoteException e) {
        throw new KeyChainException(e);
    }
}
```

## 為什麼其他選項不對

**B)** 如果完全沒有 catch，會是未處理的 checked exception，編譯不會通過。

**C)** 異常順序通常是子類在前，但 RemoteException 和 KeyChainException 沒有繼承關係。

**D)** throws 宣告會改變方法簽名，與 API 不符，編譯也會報錯。

## 相關知識
- Binder IPC 可能拋出 RemoteException
- 公開 API 應該使用特定的異常類型
- RuntimeException 是未檢查異常，會傳播到調用者

## 難度說明
**Medium** - 需要理解異常處理和 API 設計原則。
