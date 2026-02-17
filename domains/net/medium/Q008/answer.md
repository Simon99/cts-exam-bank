# Q008 解答：Uri.buildUpon().build() 丟失 fragment

## 問題根因

問題涉及兩個檔案的交互：
1. `StringUri.buildUpon()` 方法沒有調用 `.fragment()` 複製 fragment 部分
2. `UriCodec.decode()` 在解碼時錯誤地截斷了包含 `#` 的字串

## Bug 位置

1. **Uri.java** - `StringUri.buildUpon()` 方法（約第 756 行）
2. **UriCodec.java** - `decode()` 方法（約第 75 行）

## 錯誤代碼 - Uri.java

```java
public Builder buildUpon() {
    return new Builder()
            .scheme(getScheme())
            .authority(getAuthority())
            .path(getPath())
            .query(getQuery());
    // Bug: 缺少 .fragment(getFragment())
}
```

## 錯誤代碼 - UriCodec.java

```java
public static String decode(String s, boolean convertPlus, 
        Charset charset, boolean throwOnFailure) {
    // BUG: 在 fragment 解碼前錯誤地截斷
    int fragIndex = s.indexOf('#');
    if (fragIndex >= 0) {
        s = s.substring(0, fragIndex);  // 錯誤！不應該在這裡截斷
    }
    // ...
}
```

## 修復方案

### Uri.java
```java
public Builder buildUpon() {
    return new Builder()
            .scheme(getScheme())
            .authority(getAuthority())
            .path(getPath())
            .query(getQuery())
            .fragment(getFragment());  // 添加 fragment 複製
}
```

### UriCodec.java
```java
public static String decode(String s, boolean convertPlus, 
        Charset charset, boolean throwOnFailure) {
    // 不要在這裡處理 fragment 分隔符
    StringBuilder builder = new StringBuilder(s.length());
    appendDecoded(builder, s, convertPlus, charset, throwOnFailure);
    return builder.toString();
}
```

## URI 結構回顧

```
scheme://authority/path?query#fragment

例如: http://example.com/path?q=test#section1
      ^^^^   ^^^^^^^^^^^^ ^^^^ ^^^^^^ ^^^^^^^^
      scheme authority    path query  fragment
```

## 調試步驟

1. 先檢查 `buildUpon()` 是否包含 `.fragment()` 調用
2. 如果包含，檢查 `UriCodec.decode()` 是否正確處理 fragment

## 驗證命令

```bash
atest android.net.cts.UriTest#testBuildUponPreservesFragment
```

## 學習要點

- Builder 模式要確保複製所有必要的字段
- URI 由多個部分組成，fragment 是最後一部分
- 編碼/解碼邏輯需要正確處理所有 URI 組件
