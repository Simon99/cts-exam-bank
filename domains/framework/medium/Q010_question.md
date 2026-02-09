# Q010: Bundle lazy unparceling 時機錯誤

## CTS 測試失敗現象

```
android.os.cts.BundleTest#testLazyUnparcel FAILED

java.lang.IllegalStateException: Parcel data position mismatch
expected position: 156, actual position: 0
    at android.os.BaseBundle.unparcel(BaseBundle.java:345)
    at android.os.cts.BundleTest.testLazyUnparcel(BundleTest.java:1234)
```

## 測試代碼片段

```java
@Test
public void testLazyUnparcel() {
    mBundle.putString("key1", "value1");
    mBundle.putInt("key2", 100);
    
    Parcel parcel = Parcel.obtain();
    mBundle.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    Bundle restored = Bundle.CREATOR.createFromParcel(parcel);
    
    // 繼續讀取 parcel 中的其他數據（如果有的話）
    parcel.setDataPosition(parcel.dataPosition());
    
    // 觸發 lazy unparceling
    assertEquals("value1", restored.getString("key1"));  // 失敗
}
```

## 背景信息

- Bundle 使用 lazy unparceling 優化性能
- 從 Parcel 創建的 Bundle 在首次訪問數據時才真正反序列化
- 這需要正確處理 Parcel 的數據位置

## 你的任務

1. 找到導致此測試失敗的 bug
2. 理解 lazy unparceling 機制
3. 說明 bug 的根本原因
4. 提供修復方案
