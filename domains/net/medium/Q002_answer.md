# Q002 解答：LocalSocket 讀取操作拋出 ArrayIndexOutOfBoundsException

## 問題根因

`LocalSocketImpl.SocketInputStream.read()` 方法中的邊界檢查條件寫錯了。使用了 `>=` 而不是 `>`。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocketImpl.java`

**問題代碼** (約第 95 行):

```java
if (off < 0 || len < 0 || (off + len) >= b.length ) {  // Bug: >= 應該是 >
    throw new ArrayIndexOutOfBoundsException();
}
```

## 修復方案

```java
if (off < 0 || len < 0 || (off + len) > b.length ) {  // 正確：使用 >
    throw new ArrayIndexOutOfBoundsException();
}
```

## 錯誤分析

測試案例：
- `buffer.length = 10`
- `offset = 3`
- `length = 5`
- `offset + length = 8`

錯誤的檢查 `(off + len) >= b.length`：
- `8 >= 10` → false → 應該通過 ✓

但問題在於當 `offset + length == buffer.length` 時：
- 例如 `offset = 5, length = 5, buffer.length = 10`
- `5 + 5 = 10 >= 10` → true → 錯誤地拋出異常！

正確的邏輯是只有當 `off + len > b.length` 時才越界。

## 邊界條件說明

對於數組操作 `array[off]` 到 `array[off + len - 1]`：
- 最後一個訪問的索引是 `off + len - 1`
- 合法條件：`off + len - 1 < array.length`
- 等價於：`off + len <= array.length`
- 非法條件：`off + len > array.length`

## 驗證命令

```bash
atest android.net.cts.LocalSocketTest#testLocalSocketReadWithOffset
```

## 學習要點

- 邊界檢查是 off-by-one 錯誤的高發區
- `>=` vs `>` 的差異可能導致微妙的 bug
- 仔細分析索引範圍：`[off, off+len-1]`
