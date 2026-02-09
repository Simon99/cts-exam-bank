# Q005: NetworkPolicy 序列化後 warningBytes 變成 limitBytes

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.NetworkPolicyTest#testParcelable

junit.framework.AssertionFailedError: 
warningBytes mismatch after parceling
Expected: 1073741824 (1GB)
Actual: 2147483648 (2GB)
    at android.net.cts.NetworkPolicyTest.testParcelable(NetworkPolicyTest.java:112)
```

## 測試代碼片段

```java
@Test
public void testParcelable() {
    NetworkTemplate template = new NetworkTemplate.Builder(MATCH_MOBILE).build();
    
    // 創建 policy: warning = 1GB, limit = 2GB
    NetworkPolicy original = new NetworkPolicy(template, 
        buildRule(1, ZoneId.systemDefault()),
        1073741824L,   // warningBytes = 1GB
        2147483648L,   // limitBytes = 2GB
        -1, -1, true, false);
    
    // Parcel 序列化/反序列化
    Parcel parcel = Parcel.obtain();
    original.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    NetworkPolicy restored = NetworkPolicy.CREATOR.createFromParcel(parcel);
    
    // 驗證
    assertEquals(original.warningBytes, restored.warningBytes);  // ← 失敗！變成 2GB
    assertEquals(original.limitBytes, restored.limitBytes);      // ← 通過
}
```

## 問題描述

`NetworkPolicy` 經過 Parcel 序列化和反序列化後，`warningBytes` 的值變成了 `limitBytes` 的值。

## 相關代碼結構

`NetworkPolicy.java`:
```java
@Override
public void writeToParcel(Parcel dest, int flags) {
    dest.writeParcelable(template, flags);
    dest.writeParcelable(cycleRule, flags);
    dest.writeLong(warningBytes);
    dest.writeLong(limitBytes);
    // ...
}

private NetworkPolicy(Parcel source) {
    template = source.readParcelable(null);
    cycleRule = source.readParcelable(null);
    warningBytes = source.readLong();
    limitBytes = source.readLong();
    // ...
}
```

`NetworkTemplate` 和 `RecurrenceRule` 也實現了 Parcelable。

## 任務

1. 比較 `writeToParcel()` 和構造函數中的讀寫順序
2. 檢查所有字段的序列化順序是否一致
3. 找出哪個字段的順序不對
4. 修復問題

## 提示

- 涉及文件數：3（NetworkPolicy.java, NetworkTemplate.java, RecurrenceRule.java）
- 難度：Hard
- 關鍵字：Parcel、writeToParcel、readLong、順序
- 呼叫鏈：writeToParcel() → Parcel → 構造函數(Parcel)
