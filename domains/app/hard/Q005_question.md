# Q005: PendingIntent 身份識別錯誤導致權限洩漏

## CTS 測試失敗現象

執行 `android.app.cts.PendingIntentTest#testPendingIntentIdentityIsolation` 失敗

```
FAILURE: testPendingIntentIdentityIsolation
java.lang.SecurityException: 
    PendingIntent creator identity mismatch
    
    Expected creator uid: 10050 (com.app.sender)
    Actual creator uid: 10100 (com.app.malicious)
    
    Malicious app was able to reuse PendingIntent with different extras
    
    at android.app.cts.PendingIntentTest.testPendingIntentIdentityIsolation(PendingIntentTest.java:234)
```

## 測試代碼片段

```java
@Test
public void testPendingIntentIdentityIsolation() throws Exception {
    // App A 創建 PendingIntent
    Intent intent = new Intent("com.test.ACTION_PRIVILEGED");
    intent.putExtra("target", "safe_resource");
    PendingIntent piFromA = PendingIntent.getBroadcast(contextA, 0, intent,
        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
    
    // App A 將 PendingIntent 傳給 App B（惡意）
    sendPendingIntentToAppB(piFromA);
    
    // App B 嘗試重新獲取相同的 PendingIntent 並修改 extras
    Intent maliciousIntent = new Intent("com.test.ACTION_PRIVILEGED");
    maliciousIntent.putExtra("target", "sensitive_data");
    PendingIntent piFromB = PendingIntent.getBroadcast(contextB, 0, maliciousIntent,
        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
    
    // 這不應該成功：B 不應該能更新 A 的 PendingIntent
    int creatorUid = piFromB.getCreatorUid();
    assertEquals("Creator should still be App A", uidA, creatorUid);
    
    // 驗證 extras 沒有被 B 修改
    Intent resultIntent = extractIntentFromPendingIntent(piFromB);
    assertEquals("safe_resource", resultIntent.getStringExtra("target"));
}
```

## 症狀描述

- App A 創建 PendingIntent 指向敏感操作
- App B（惡意）能夠通過創建「匹配」的 PendingIntent 獲取到 A 的 PendingIntent
- 使用 FLAG_UPDATE_CURRENT，B 成功修改了 A 的 PendingIntent 的 extras
- 導致 A 的身份被用來執行 B 想要的操作（權限洩漏）

## 你的任務

1. 分析 PendingIntent 的身份識別和匹配機制
2. 理解 FLAG_UPDATE_CURRENT 和 FLAG_MUTABLE 的安全影響
3. 找出身份驗證不足的位置
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/services/core/java/com/android/server/am/PendingIntentRecord.java`
  - `frameworks/base/services/core/java/com/android/server/am/PendingIntentController.java`
  - `frameworks/base/core/java/android/app/PendingIntent.java`
- 關注 `PendingIntentController.getIntentSender()` 的匹配邏輯
- 關注 `Key.equals()` 的實現
