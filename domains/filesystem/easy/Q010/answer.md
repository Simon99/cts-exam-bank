# Q010 答案解析

## 問題根因
`CrateInfo.getLabel()` 被錯誤地返回空字符串 `""`，
而不是返回 `mLabel` 成員變量。

## 修復位置
`frameworks/base/core/java/android/os/storage/CrateInfo.java`

## 修復方法
返回 `mLabel` 而不是空字符串。

## 原始代碼
```java
@NonNull
public CharSequence getLabel() {
    return "";  // Bug: 應該返回 mLabel
}
```

## 修復後代碼
```java
@NonNull
public CharSequence getLabel() {
    return mLabel;
}
```

## 知識點
1. `CrateInfo` 用於描述應用的 Crate 目錄信息
2. Crate 是 Android 的存儲分類機制
3. Label 默認使用目錄名稱，除非應用顯式設置
4. 這類簡單的返回值錯誤很容易定位

## 調試技巧
1. 從測試期望的行為入手
2. 檢查相關 getter 方法的實現
3. 確認返回值是否使用了正確的成員變量
