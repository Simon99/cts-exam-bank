# Q008 答案解析

## Bug 位置

`frameworks/base/location/java/android/location/GnssMeasurement.java` 的 `writeToParcel()` 或 Parcel 建構子

## Bug 描述

在 `writeToParcel()` 或從 Parcel 讀取時，`mCn0DbHz` 欄位被遺漏。

原始正確代碼（writeToParcel）：
```java
public void writeToParcel(Parcel parcel, int flags) {
    // ... 其他欄位
    parcel.writeDouble(mCn0DbHz);
    // ...
}
```

Bug 代碼（遺漏寫入）：
```java
public void writeToParcel(Parcel parcel, int flags) {
    // ... 其他欄位
    // parcel.writeDouble(mCn0DbHz);  // 這行被刪除了
    // ...
}
```

## 修復方式

確保 `writeToParcel()` 中包含 `parcel.writeDouble(mCn0DbHz)`，並且在讀取時也正確讀取。

## 調試思路

1. 測試顯示序列化後再讀取，cn0DbHz 變成 0.0
2. 查看 GnssMeasurement 的 writeToParcel() 和 Parcel 建構子
3. 找到序列化或反序列化中遺漏的欄位

## 涉及檔案

1. `frameworks/base/location/java/android/location/GnssMeasurement.java`
