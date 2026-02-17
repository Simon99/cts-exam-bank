# Q003: Criteria Copy Constructor NullPointerException Missing

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.CriteriaTest#testConstructor
java.lang.AssertionError: Expected NullPointerException to be thrown
    at android.location.cts.none.CriteriaTest.testConstructor(CriteriaTest.java:51)
```

## 失敗的測試代碼片段

```java
try {
    new Criteria(null);
    fail("should throw NullPointerException.");  // ← 這裡失敗，沒有拋出異常
} catch (NullPointerException e) {
    // expected.
}
```

## 問題描述

當傳入 `null` 給 `Criteria` 的拷貝建構子時，應該拋出 `NullPointerException`，但實際上沒有拋出異常。

## 相關源碼位置

- `frameworks/base/location/java/android/location/Criteria.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
