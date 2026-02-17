# SEC-M010: SELinux Context 驗證字串解析錯誤

## CTS Test
`android.security.cts.SELinuxHostTest#testContextFormat`

## Failure Log
```
junit.framework.AssertionFailedError: SELinux context parsing failed
Expected context parts: [user, role, type, range]
Actual: Only 3 parts parsed

Full context: "u:r:untrusted_app:s0:c123,c456"
Parsed: ["u", "r", "untrusted_app"]
Missing: MLS range "s0:c123,c456"

at android.security.cts.SELinuxHostTest.testContextFormat(SELinuxHostTest.java:234)
```

## 現象描述
SELinux context 解析時只解析出 3 個部分，
遺漏了 MLS (Multi-Level Security) range。
完整的 context 應該有 4 個部分。

## 提示
- SELinux context 格式：user:role:type:range
- 分隔符是冒號 (`:`)
- MLS range 本身可能包含冒號（如 `s0:c123`）

## 選項

A) `split(":")` 沒有限制分割次數，導致 range 被過度分割

B) `split(":")` 限制只分割 3 次，遺漏了 range 部分

C) 解析後的陣列索引從 1 開始，跳過了第一個元素

D) range 部分的冒號被錯誤地當成分隔符處理
