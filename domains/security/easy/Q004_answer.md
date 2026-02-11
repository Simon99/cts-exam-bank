# Q004 Answer: Key Size Validation

## 正確答案
**C) LINE C 傳入的是 TAG 本身而非 TAG 的值**

## 問題根因
`findTag(TAG_KEY_SIZE)` 返回的是整個 TAG 結構（通常是一個序列或標記類型），
而不是 TAG 內部的整數值。傳入 `parseKeySize()` 時，primitive 不是 ASN1Integer，
因此進入 else 分支返回 0。

正確做法是應該提取 TAG 內部的值再傳入解析函數。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
public Integer getKeySize() {
    ASN1Primitive keySizeTag = findTag(TAG_KEY_SIZE);
    if (keySizeTag == null) {
        return null;
    }
    return parseKeySize(keySizeTag);  // BUG: 傳入 TAG 本身
}

// 正確的代碼
public Integer getKeySize() {
    ASN1Primitive keySizeTag = findTag(TAG_KEY_SIZE);
    if (keySizeTag == null) {
        return null;
    }
    ASN1Primitive value = extractTagValue(keySizeTag);  // 提取 TAG 內的值
    return parseKeySize(value);
}
```

## 選項分析
- **A) 錯誤** - Java 自動裝箱，int 會自動轉換為 Integer
- **B) 錯誤** - 返回 0 vs null 不是導致問題的原因
- **C) 正確** - 傳入錯誤的資料結構導致類型不匹配
- **D) 錯誤** - intValueExact() 是正確的方法

## 相關知識
- ASN.1 TAG 結構包含標籤號、長度和值
- KeyMaster TAG 使用隱式標籤格式
- 解析時需要正確提取標籤內的實際數據

## 難度說明
**Easy** - 理解 ASN.1 TAG 結構即可發現傳入參數錯誤。
