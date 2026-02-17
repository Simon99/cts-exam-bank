# Q004: Authorization Tag Parsing

## CTS Test
`android.keystore.cts.AuthorizationListTest#testTagParsing`

## Failure Log
```
junit.framework.AssertionFailedError: 
Failed to parse authorization tag
Tag type mismatch for TAG_PURPOSE
Expected: ENUM_REP (repeatable enumeration)
Actual: interpreted as UINT

at android.keystore.cts.AuthorizationListTest.testTagParsing(AuthorizationListTest.java:78)
```

## 現象描述
CTS 測試報告授權標籤解析錯誤。TAG_PURPOSE 應該被解析為可重複的枚舉類型，
但被錯誤地解析為無符號整數。

## 提示
- KeyMaster 標籤由類型和 ID 組成：(type << 28) | id
- 類型決定如何解析標籤值
- 問題出在標籤類型提取邏輯

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
private static final int TAG_TYPE_MASK = 0x0FFFFFFF;  // LINE A
private static final int TAG_TYPE_SHIFT = 28;

public static int getTagType(int tag) {
    return (tag & TAG_TYPE_MASK) >> TAG_TYPE_SHIFT;  // LINE B
}

public static int getTagId(int tag) {
    return tag & TAG_TYPE_MASK;
}

// Tag types
public static final int TYPE_UINT = 1;
public static final int TYPE_ENUM_REP = 5;

// Tags (type << 28 | id)
public static final int TAG_PURPOSE = (TYPE_ENUM_REP << 28) | 1;  // 0x50000001
```

A) TAG_TYPE_MASK 應該是 0xF0000000 而非 0x0FFFFFFF
B) TAG_TYPE_SHIFT 應該是 24 而非 28
C) LINE B 的位元操作順序錯誤
D) TAG_PURPOSE 的定義應該使用不同的 ID
