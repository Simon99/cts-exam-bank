# SEC-H003 Answer: KeyChain 對話框別名選擇競爭條件

## 正確答案
**A) 使用 static 變數儲存 callback，被後續請求覆蓋**

## 問題根因
在 `KeyChain.java` 的 `choosePrivateKeyAlias()` 方法中，
使用了 static 變數儲存 callback 物件。當多個請求同時進行時，
後面的請求會覆蓋前面請求的 callback。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
private static KeyChainAliasCallback sCallback;  // BUG: static

public static void choosePrivateKeyAlias(Activity activity,
        KeyChainAliasCallback callback, ...) {
    sCallback = callback;  // 被覆蓋
    startAliasChooserActivity(activity, ...);
}

// 正確的代碼（使用 Map 儲存請求-callback 對應）
private static final Map<Integer, KeyChainAliasCallback> sCallbacks =
        new ConcurrentHashMap<>();
private static final AtomicInteger sRequestId = new AtomicInteger(0);

public static void choosePrivateKeyAlias(Activity activity,
        KeyChainAliasCallback callback, ...) {
    int requestId = sRequestId.incrementAndGet();
    sCallbacks.put(requestId, callback);
    startAliasChooserActivity(activity, requestId, ...);
}
```

## 為什麼其他選項不對

**B)** 非執行緒安全的計數器會導致重複 ID，但不會造成錯誤的 callback 匹配。

**C)** Handler 問題會導致回調在錯誤的執行緒執行，不會導致收到錯誤的結果。

**D)** Intent 遺失資訊會導致無法識別請求，但錯誤訊息顯示收到了錯誤的別名。

## 相關知識
- 競爭條件是並發程式設計的常見問題
- static 變數在多執行緒環境需要特別小心
- Android 的回調機制需要正確處理並發請求

## 難度說明
**Hard** - 需要理解並發程式設計和競爭條件的概念。
