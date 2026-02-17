# Q003 答案解析

## Bug 位置

`frameworks/base/location/java/android/location/Criteria.java` 的拷貝建構子

## Bug 描述

拷貝建構子中添加了 null 檢查，導致不再拋出 NullPointerException。

原始正確代碼：
```java
public Criteria(Criteria criteria) {
    mHorizontalAccuracy = criteria.mHorizontalAccuracy;
    mVerticalAccuracy = criteria.mVerticalAccuracy;
    mSpeedAccuracy = criteria.mSpeedAccuracy;
    // ... 直接訪問 criteria，null 時會自然拋出 NPE
}
```

Bug 代碼：
```java
public Criteria(Criteria criteria) {
    if (criteria == null) {
        return;  // 錯誤：靜默處理 null，應該讓它拋出 NPE
    }
    mHorizontalAccuracy = criteria.mHorizontalAccuracy;
    // ...
}
```

## 修復方式

移除添加的 null 檢查，讓代碼自然拋出 NullPointerException。

## 調試思路

1. 測試期望傳入 null 時拋出 NullPointerException
2. 查看 Criteria 拷貝建構子
3. 發現有人添加了 null 檢查來「防禦」null 輸入
4. 但這破壞了 API 契約，CTS 期望的是拋出異常

## 涉及檔案

1. `frameworks/base/location/java/android/location/Criteria.java`
