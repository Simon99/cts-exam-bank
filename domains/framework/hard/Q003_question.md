# Q003: Intent 多組件交互時 ClipData 權限傳遞失敗

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testClipDataUriPermission FAILED

java.lang.SecurityException: Permission Denial: reading 
com.android.providers.media.MediaProvider uri 
content://media/external/images/media/123 
from pid=12345, uid=10086 requires that you obtain access using 
ACTION_OPEN_DOCUMENT or related APIs
    at android.content.cts.IntentTest.testClipDataUriPermission(IntentTest.java:2345)
```

## 測試代碼片段

```java
@Test
public void testClipDataUriPermission() {
    Intent intent = new Intent(Intent.ACTION_SEND);
    intent.setType("image/*");
    
    Uri imageUri = Uri.parse("content://media/external/images/media/123");
    ClipData clip = ClipData.newUri(mContext.getContentResolver(), "Image", imageUri);
    intent.setClipData(clip);
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    
    // 模擬跨進程傳遞
    Parcel parcel = Parcel.obtain();
    intent.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    Intent restored = Intent.CREATOR.createFromParcel(parcel);
    
    // 檢查 ClipData 和權限 flag 是否正確傳遞
    assertNotNull(restored.getClipData());
    assertTrue((restored.getFlags() & Intent.FLAG_GRANT_READ_URI_PERMISSION) != 0);
    
    // 嘗試訪問 URI（應該有權限）
    mContext.getContentResolver().openInputStream(
        restored.getClipData().getItemAt(0).getUri()).close();
}
```

## 背景信息

- Intent 可以通過 ClipData 傳遞 URI
- FLAG_GRANT_READ_URI_PERMISSION 授予臨時 URI 權限
- 這涉及 Intent、ClipData、權限系統的交互

## 你的任務

1. 追蹤 ClipData 和權限 flag 的序列化流程
2. 理解 URI 權限授予機制
3. 找出權限丟失的原因
4. 提供修復方案
