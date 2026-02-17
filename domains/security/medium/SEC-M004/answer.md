# SEC-M004 Answer: Digest 列表解析使用錯誤的 TAG

## 正確答案
**A) 解析 Digest 時使用了 `KM_TAG_PURPOSE` 而非 `KM_TAG_DIGEST`**

## 問題根因
在 `AuthorizationList.java` 解析 TAG 時，
處理 Digest 的 case 使用了錯誤的 TAG 常數 `KM_TAG_PURPOSE`，
導致解析到的是 Purpose 的值而非 Digest 的值。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
switch (tag) {
    case KM_TAG_PURPOSE:  // BUG: 應該是 KM_TAG_DIGEST
        parseDigests(value);
        break;
    // ...
}

// 正確的代碼
switch (tag) {
    case KM_TAG_DIGEST:
        parseDigests(value);
        break;
    // ...
}
```

## 為什麼其他選項不對

**B)** 常數值不一致會導致解析出錯誤的值，但不會是 Purpose 的值列表 [1,2,3]。

**C)** 加入錯誤列表會讓 Digest 列表為空，不會包含 Purpose 的值。

**D)** 返回 getPurposes() 會在測試 getPurposes() 時也發現問題。

## 相關知識
- KM_TAG_DIGEST = 0x20000005
- KM_TAG_PURPOSE = 0x20000001
- TAG 定義在 KeyMaster HAL 規格中
- 使用錯誤的 TAG 會解析到完全不同的資料

## 難度說明
**Medium** - 需要理解 TAG-based 解析邏輯和常數的對應關係。
