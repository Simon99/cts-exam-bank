# Q003: Intent 序列化時 Flags 損壞導致狀態不一致

## CTS 測試失敗現象

```
android.content.cts.IntentTest#testReadFromParcel FAILED

junit.framework.AssertionFailedError: expected:<0> but was:<1>
    at junit.framework.Assert.assertEquals(Assert.java:67)
    at android.content.cts.IntentTest.testReadFromParcel(IntentTest.java:149)
```

## 測試代碼片段

```java
@Test
public void testReadFromParcel() {
    // 創建原始 Intent
    Intent originalIntent = new Intent();
    // mFlags 默認為 0
    
    // 序列化到 Parcel
    Parcel parcel = Parcel.obtain();
    originalIntent.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    // 從 Parcel 反序列化
    Intent restoredIntent = Intent.CREATOR.createFromParcel(parcel);
    
    // 驗證所有字段一致
    assertEquals(originalIntent.getAction(), restoredIntent.getAction());
    assertEquals(originalIntent.getFlags(), restoredIntent.getFlags());  // 失敗！
    // ... 其他字段檢查
}
```

## 錯誤訊息分析

```
expected:<0> but was:<1>
```

- 原始 Intent 的 flags = 0
- 反序列化後的 Intent flags = 1
- 序列化/反序列化過程中 flags 被意外修改

## 背景信息

- Intent 是 Android IPC 的核心，必須保證序列化/反序列化的一致性
- `mFlags` 控制 Intent 的行為（如 FLAG_ACTIVITY_NEW_TASK、FLAG_GRANT_READ_URI_PERMISSION 等）
- Parcel 機制必須精確保存所有字段

## 你的任務

1. 追蹤 `Intent.writeToParcel()` 和 `readFromParcel()` 的實現
2. 找出 `mFlags` 在哪裡被修改
3. 解釋為什麼 0 變成了 1
4. 提供修復方案
