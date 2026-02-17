# Q005: Intent PendingIntent 序列化安全漏洞

## CTS 測試失敗現象

```
android.content.cts.PendingIntentTest#testPendingIntentSecurity FAILED

java.lang.SecurityException: Intent target mismatch: 
requested com.target.app/.Activity but resolved to com.attacker.app/.Activity
    at android.app.PendingIntent.send(PendingIntent.java:1234)
    at android.content.cts.PendingIntentTest.testPendingIntentSecurity(PendingIntentTest.java:567)
```

## 測試代碼片段

```java
@Test
public void testPendingIntentSecurity() {
    Intent original = new Intent();
    original.setComponent(new ComponentName("com.target.app", ".Activity"));
    original.putExtra("sensitive_data", "secret");
    
    PendingIntent pending = PendingIntent.getActivity(mContext, 0, original, 
        PendingIntent.FLAG_IMMUTABLE);
    
    // 序列化 PendingIntent
    Parcel parcel = Parcel.obtain();
    pending.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    PendingIntent restored = PendingIntent.CREATOR.createFromParcel(parcel);
    
    // 驗證安全性：不應該允許修改目標組件
    Intent fillIn = new Intent();
    fillIn.setComponent(new ComponentName("com.attacker.app", ".Activity"));
    
    // 這裡應該失敗或忽略 fillIn 的組件
    restored.send(mContext, 0, fillIn);
}
```

## 背景信息

- PendingIntent 封裝了發送者的身份和權限
- FLAG_IMMUTABLE 應該阻止 Intent 被修改
- 涉及 Intent、PendingIntent、ActivityManagerService

## 你的任務

1. 追蹤 PendingIntent 的序列化和安全檢查
2. 理解 FLAG_IMMUTABLE 的實現
3. 找出安全檢查失效的原因
4. 提供修復方案
