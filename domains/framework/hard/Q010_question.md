# Q010: IntentFilter 序列化時 mOrder 和 mPriority 順序錯誤

## CTS 測試失敗現象

```
android.content.cts.IntentFilterTest#testParceling FAILED

java.lang.AssertionError: 
Expected priority: 100
Actual priority: 5
Expected order: 5
Actual order: 100
    at android.content.cts.IntentFilterTest.testParceling(IntentFilterTest.java:1123)
```

## 測試代碼片段

```java
@Test
public void testParceling() throws Exception {
    IntentFilter original = new IntentFilter();
    original.addAction(Intent.ACTION_VIEW);
    original.addCategory(Intent.CATEGORY_DEFAULT);
    original.setPriority(100);
    original.setOrder(5);
    
    // 序列化
    Parcel parcel = Parcel.obtain();
    original.writeToParcel(parcel, 0);
    parcel.setDataPosition(0);
    
    // 反序列化
    IntentFilter restored = IntentFilter.CREATOR.createFromParcel(parcel);
    parcel.recycle();
    
    // 驗證基本屬性
    assertEquals(original.countActions(), restored.countActions());
    assertEquals(original.getAction(0), restored.getAction(0));
    
    // 驗證 priority 和 order - 這裡失敗
    assertEquals("Priority mismatch", 100, restored.getPriority());  // ← 得到 5
    assertEquals("Order mismatch", 5, restored.getOrder());          // ← 得到 100
}
```

## 問題描述

IntentFilter 經過 Parcel 序列化再反序列化後，`priority` 和 `order` 的值互換了。這表明在 `writeToParcel()` 和 `IntentFilter(Parcel)` 構造函數中，這兩個欄位的讀寫順序不一致。

## 相關源碼位置

- `frameworks/base/core/java/android/content/IntentFilter.java` - writeToParcel() 和 IntentFilter(Parcel) 方法

## 調試提示

需要追蹤：
1. `writeToParcel()` 中 mPriority 和 mOrder 的寫入順序
2. `IntentFilter(Parcel source)` 構造函數中的讀取順序
3. Parcel 的順序敏感特性

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
