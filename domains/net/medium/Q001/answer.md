# Q001 解答：Uri.getQueryParameter 返回 null

## 問題根因

在 `Uri.java` 的 `getQueryParameter()` 方法中，調用 `UriCodec.decode()` 時，`convertPlus` 參數被錯誤地設為 `false`（應為 `true`）。

根據 URL 編碼規範，查詢參數中的 `+` 符號應該被解碼為空格。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/Uri.java`

**問題代碼** (約第 1856 行):

```java
String value = UriCodec.decode(query.substring(separator + 1, end), false,  // Bug: 應該是 true
        StandardCharsets.UTF_8, false);
```

## 修復方案

```java
String value = UriCodec.decode(query.substring(separator + 1, end), true,  // 正確：convertPlus = true
        StandardCharsets.UTF_8, false);
```

## 調試過程

1. 從測試看到 `getQueryParameter("q")` 返回 null
2. 追蹤 `Uri.getQueryParameter()` → 發現調用 `UriCodec.decode()`
3. 查看 `UriCodec.decode()` 的簽名：`decode(String s, boolean convertPlus, ...)`
4. 當 `convertPlus=false` 時，`+` 不會被轉換為空格
5. 導致解碼後的值不正確，查找失敗返回 null

## UriCodec.decode 參數說明

```java
public static String decode(
    String s,           // 要解碼的字串
    boolean convertPlus, // 是否將 + 轉換為空格
    Charset charset,    // 字符集
    boolean throwOnFailure  // 失敗時是否拋異常
)
```

## 驗證命令

```bash
atest android.net.cts.UriTest#testGetQueryParameter
```

## 學習要點

- URL 查詢參數中 `+` 是空格的合法編碼方式
- `application/x-www-form-urlencoded` 規範定義了這個行為
- 仔細審查 API 調用時的參數值
