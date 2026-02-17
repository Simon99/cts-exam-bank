# Q002: ContentProvider 跨進程權限驗證失敗

## CTS 測試失敗現象

執行 `android.content.cts.ContentProviderClientTest#testGrantUriPermission` 失敗

```
FAILURE: testGrantUriPermission
java.lang.SecurityException: Permission Denial: opening provider 
    com.android.cts.stub.StubContentProvider from ProcessRecord{abc1234 12345:com.test/u0a100} 
    (pid=12345, uid=10100) requires android.permission.READ_CONTACTS or grantUriPermission()
    
    Expected: grant should allow access without READ_CONTACTS
    Actual: SecurityException thrown
    
    at android.content.cts.ContentProviderClientTest.testGrantUriPermission(ContentProviderClientTest.java:245)
```

## 測試代碼片段

```java
@Test
public void testGrantUriPermission() throws Exception {
    Uri contentUri = Uri.parse("content://com.android.cts.stub/contacts/1");
    
    // App A 持有 READ_CONTACTS 權限，授予臨時權限給 App B
    Intent intent = new Intent(Intent.ACTION_VIEW, contentUri);
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    
    // App B 沒有 READ_CONTACTS，但應該能通過授權訪問
    mContext.grantUriPermission("com.test.appB", contentUri, 
        Intent.FLAG_GRANT_READ_URI_PERMISSION);
    
    // 切換到 App B 的 context 嘗試訪問
    Context appBContext = createPackageContext("com.test.appB", 0);
    ContentResolver resolver = appBContext.getContentResolver();
    
    // 這裡應該成功，因為有 grantUriPermission
    Cursor cursor = resolver.query(contentUri, null, null, null, null);
    assertNotNull("Should be able to access with granted permission", cursor);
}
```

## 症狀描述

- App A 使用 `grantUriPermission()` 授予 App B 臨時讀取權限
- App B 訪問 URI 時仍然拋出 SecurityException
- 權限授予似乎沒有被正確記錄或檢查

## 你的任務

1. 追蹤 `grantUriPermission()` 的完整調用鏈
2. 分析 ContentProvider 權限檢查的機制
3. 找出權限授予與檢查不一致的原因
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/services/core/java/com/android/server/uri/UriGrantsManagerService.java`
  - `frameworks/base/services/core/java/com/android/server/uri/GrantUri.java`
  - `frameworks/base/services/core/java/com/android/server/am/ContentProviderHelper.java`
- 關注 `GrantUri.equals()` 和 `hashCode()` 的實現
- 關注權限在 Map 中如何被存儲和查找
- ContentProviderHelper 中的權限檢查流程
