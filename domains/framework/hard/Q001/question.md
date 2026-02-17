# Q001: Intent 跨進程傳遞時 Parcelable 序列化失敗

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testParcelableAcrossProcesses FAILED

android.os.BadParcelableException: Parcelable protocol requires that 
the constructor take a Parcel as its only argument
    at android.os.Parcel.readParcelableInternal(Parcel.java:3567)
    at android.os.BaseBundle.unparcel(BaseBundle.java:456)
    at android.content.Intent.getParcelableExtra(Intent.java:8234)
```

## 測試代碼片段

```java
@Test
public void testParcelableAcrossProcesses() {
    Intent intent = new Intent();
    CustomData data = new CustomData("test", 123);
    intent.putExtra("data", data);
    
    // 模擬跨進程傳遞
    Parcel parcel = Parcel.obtain();
    intent.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    Intent restored = Intent.CREATOR.createFromParcel(parcel);
    restored.setExtrasClassLoader(CustomData.class.getClassLoader());
    
    CustomData restoredData = restored.getParcelableExtra("data", CustomData.class);
    assertEquals("test", restoredData.getName());
    assertEquals(123, restoredData.getValue());
}
```

## 背景信息

- 自定義 Parcelable 需要 CREATOR 和正確的構造函數
- 跨進程傳遞時，類加載和序列化流程較複雜
- 涉及 Intent → Bundle → Parcel → Parcelable.Creator 的完整鏈路

## 你的任務

1. 追蹤完整的序列化/反序列化流程
2. 定位導致失敗的具體位置
3. 理解多個組件如何交互
4. 提供修復方案
