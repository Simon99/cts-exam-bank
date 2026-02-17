# SEC-H003: KeyChain 對話框別名選擇競爭條件

## CTS Test
`android.keychain.cts.KeyChainTest#testChoosePrivateKeyAliasRaceCondition`

## Failure Log
```
junit.framework.AssertionFailedError: Key alias selection race condition detected
Test spawned 10 concurrent alias selection requests.
Expected: All callbacks receive the selected alias OR null
Actual: Some callbacks received wrong alias from different request

Thread-1 selected "alias-A" but Thread-3 callback received "alias-A" (belongs to Thread-1)
at android.keychain.cts.KeyChainTest.testChoosePrivateKeyAliasRaceCondition(KeyChainTest.java:287)
```

## 相關測試上下文
```java
// 測試並發選擇別名時是否有競爭條件
for (int i = 0; i < 10; i++) {
    new Thread(() -> KeyChain.choosePrivateKeyAlias(activity, callback, ...)).start();
}
// 驗證每個 callback 收到的是自己請求的結果
```

## 現象描述
當多個執行緒同時呼叫 `choosePrivateKeyAlias()` 時，
回調函數可能收到錯誤的別名，這是另一個請求的結果。

## 提示
- 競爭條件 (Race Condition) 發生在共享可變狀態時
- 可能是使用了 static 變數儲存回調
- 問題可能在於請求和回調的配對機制

## 選項

A) 使用 static 變數儲存 callback，被後續請求覆蓋

B) 請求 ID 的產生使用了非執行緒安全的計數器

C) 回調的分發使用了錯誤的 Handler，導致跨執行緒問題

D) 對話框的結果透過 Intent 傳遞時遺失了請求識別資訊
