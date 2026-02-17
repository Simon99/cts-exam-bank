# Q004 Answer: Authorization Tag Parsing

## 正確答案
**A) TAG_TYPE_MASK 應該是 0xF0000000 而非 0x0FFFFFFF**

## 問題根因
`TAG_TYPE_MASK = 0x0FFFFFFF` 是提取低 28 位的遮罩，用於獲取 tag ID。
但 `getTagType()` 使用這個遮罩來提取類型，這是錯誤的。

提取高 4 位類型應該使用 `0xF0000000` 遮罩。當前邏輯：
- `(0x50000001 & 0x0FFFFFFF) >> 28` = `0x00000001 >> 28` = `0`

正確邏輯：
- `(0x50000001 & 0xF0000000) >> 28` = `0x50000000 >> 28` = `5`

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
private static final int TAG_TYPE_MASK = 0x0FFFFFFF;

public static int getTagType(int tag) {
    return (tag & TAG_TYPE_MASK) >> TAG_TYPE_SHIFT;  // 結果永遠是 0
}

// 正確的代碼 - 使用不同的遮罩
private static final int TAG_TYPE_MASK = 0xF0000000;

public static int getTagType(int tag) {
    return (tag & TAG_TYPE_MASK) >> TAG_TYPE_SHIFT;  // 正確提取高 4 位
}
```

## 選項分析
- **A) 正確** - 遮罩值錯誤，應該是 0xF0000000
- **B) 錯誤** - 28 位位移是正確的（32 - 4 = 28）
- **C) 錯誤** - 先 AND 再 SHIFT 是正確順序
- **D) 錯誤** - TAG_PURPOSE 的定義沒有問題

## 相關知識
- KeyMaster 標籤編碼：高 4 位類型 + 低 28 位 ID
- 位元遮罩操作：AND 提取特定位
- 常見類型：UINT(1), UINT_REP(2), ENUM(3), ENUM_REP(5)

## 難度說明
**Medium** - 需要理解位元運算和標籤編碼格式。
