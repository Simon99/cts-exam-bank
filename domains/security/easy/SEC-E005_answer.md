# SEC-E005 Answer: Padding Mode 驗證錯誤

## 正確答案
**C) `getPaddings()` 返回了新建的空列表而非成員變數**

## 問題根因
在 `AuthorizationList.java` 的 `getPaddings()` 方法中，
返回了 `new ArrayList<>()` 而非儲存解析結果的成員變數 `mPaddings`。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
public List<Integer> getPaddings() {
    return new ArrayList<>();  // BUG: 返回空列表
}

// 正確的代碼
public List<Integer> getPaddings() {
    return mPaddings;
}
```

## 為什麼其他選項不對

**A)** 如果加入錯誤列表，其他相關測試可能會發現異常，不會只有 padding 為空。

**B)** 缺少 break 會導致 fall-through，可能會有額外的值被加入，不會是空列表。

**D)** 常數值不一致會導致解析出錯誤的值，不會是完全空的列表。

## 相關知識
- PKCS#1 v1.5 是傳統的 RSA 填充方式
- OAEP (Optimal Asymmetric Encryption Padding) 是較安全的填充方式
- Getter 方法返回錯誤值是常見的實作錯誤

## 難度說明
**Easy** - 返回空列表是明顯的錯誤，從 fail log 的「Empty padding list」可直接判斷。
