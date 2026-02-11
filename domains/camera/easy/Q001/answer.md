# 答案

**正確答案：B**

## 解釋

條件 `requests == null && requests.isEmpty()` 使用了邏輯 AND（`&&`），這是錯誤的：

1. 如果 `requests == null`，短路求值會阻止 `requests.isEmpty()` 被調用（避免 NPE），但條件仍為 false（因為需要兩者都為 true）
2. 如果 `requests` 不是 null 但是空列表，`requests == null` 為 false，整個條件為 false
3. **結果**：空列表不會被攔截，會傳給 `submitCaptureRequest()` 導致後續錯誤

## 正確寫法

```java
if (requests == null || requests.isEmpty()) {
    throw new IllegalArgumentException("At least one request must be given");
}
```

使用邏輯 OR（`||`），任一條件成立都會拋出異常。

## Bug 影響

- **CTS 測試**：BurstCaptureTest 相關測試會失敗
- **實際影響**：App 傳入空列表時不會得到明確的錯誤訊息，而是在後續流程中產生難以追蹤的異常

## 為什麼其他選項錯誤

- **A**：`isEmpty()` 和 `size() == 0` 功能相同，不是問題所在
- **C**：檢查順序不影響結果，而且先檢查 null 是正確的防禦性編程
- **D**：executor 的 null 檢查在 `submitCaptureRequest()` 內部處理，這裡不需要
