# Q007 答案解析

## Bug 位置

`frameworks/base/location/java/android/location/Criteria.java` 的 `setAccuracy()` 方法

## Bug 描述

`setAccuracy()` 方法的參數驗證被移除或條件錯誤。

原始正確代碼：
```java
public void setAccuracy(@LocationAccuracyRequirement int accuracy) {
    if (accuracy < NO_REQUIREMENT || accuracy > ACCURACY_COARSE) {
        throw new IllegalArgumentException("accuracy=" + accuracy);
    }
    mHorizontalAccuracy = accuracy;
}
```

Bug 代碼（驗證被移除）：
```java
public void setAccuracy(@LocationAccuracyRequirement int accuracy) {
    // 驗證代碼被刪除
    mHorizontalAccuracy = accuracy;
}
```

## 修復方式

恢復參數範圍驗證，當 accuracy 不在有效範圍內時拋出 IllegalArgumentException。

## 調試思路

1. 測試期望傳入 -1 時拋出 IllegalArgumentException
2. 查看 Criteria.setAccuracy() 方法
3. 發現缺少參數驗證

## 涉及檔案

1. `frameworks/base/location/java/android/location/Criteria.java`
