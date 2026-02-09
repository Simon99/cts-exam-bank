# Q007: Criteria.setAccuracy() Not Rejecting Invalid Values

## CTS 測試失敗現象

```
FAIL: android.location.cts.none.CriteriaTest#testAccessAccuracy
java.lang.AssertionError: Expected IllegalArgumentException to be thrown
    at android.location.cts.none.CriteriaTest.testAccessAccuracy(CriteriaTest.java:77)
```

## 失敗的測試代碼片段

```java
try {
    criteria.setAccuracy(-1);
    // fail() 應該不會執行，因為應該拋出異常
} catch (IllegalArgumentException e) {
    // expected.
}
```

## 問題描述

當傳入無效的 accuracy 值（如 -1）給 `setAccuracy()` 時，應該拋出 `IllegalArgumentException`，但實際上沒有拋出。

## 相關源碼位置

- `frameworks/base/location/java/android/location/Criteria.java`

## 任務

找出導致此 CTS 測試失敗的 bug 並修復。
