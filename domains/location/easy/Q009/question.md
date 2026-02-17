# Q009: Location.set() Does Not Copy Provider

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.LocationTest#testSet
java.lang.AssertionError: 
Expected location to be equal to source
    at android.location.cts.none.LocationTest.testSet(LocationTest.java:84)
```

## 失敗的測試代碼片段

```java
Location l = new Location("test");
l.setProvider("test");
l.setTime(1);
// ... 設定其他欄位

location.set(l);
assertThat(location).isEqualTo(l);  // ← 失敗，location 與 l 不相等
```

## 問題描述

呼叫 `Location.set()` 複製另一個 Location 後，兩個物件應該相等，但測試失敗表明某些欄位沒有被正確複製。

## 相關源碼位置

- `frameworks/base/core/java/android/location/Location.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
