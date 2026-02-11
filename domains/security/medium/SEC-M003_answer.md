# SEC-M003 Answer: AuthorizationList Purpose 驗證邏輯錯誤

## 正確答案
**A) 解析 Purpose TAG 時在找到第一個值後就 break 了**

## 問題根因
在 `AuthorizationList.java` 解析 Purpose TAG 時，
switch case 處理完第一個值後錯誤地執行了 break，
導致後續的 Purpose 值沒有被處理。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
for (ASN1Encodable value : purposeSequence) {
    int purpose = ((ASN1Integer) value).intValueExact();
    mPurposes.add(purpose);
    break;  // BUG: 不該在這裡 break
}

// 正確的代碼
for (ASN1Encodable value : purposeSequence) {
    int purpose = ((ASN1Integer) value).intValueExact();
    mPurposes.add(purpose);
    // 繼續處理下一個 purpose
}
```

## 為什麼其他選項不對

**B)** 返回只有第一個元素的列表，會在 getter 而非解析時發生，stack trace 會不同。

**C)** 使用 `=` 而非 `+=` 會覆蓋而非累加，但 list 用 add() 不是這種情況。

**D)** 如果列表每次被清空，根據解析順序，最後一個值會存在，不一定是第一個。

## 相關知識
- KeyMaster 的 Purpose TAG 可以包含多個用途
- 多值 TAG 需要用迴圈完整處理
- switch 中的 break 和迴圈中的 break 容易混淆

## 難度說明
**Medium** - 需要理解多值 TAG 的解析邏輯和 break 的影響範圍。
