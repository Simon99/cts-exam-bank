# Q003 解答：Uri.Builder 連續調用 appendPath 導致路徑錯誤

## 問題根因

問題涉及三個檔案的交互：
1. `Uri.java` 中 `PathPart.appendDecodedSegment()` 沒有正確累積路徑
2. `UriCodec.java` 錯誤地編碼路徑分隔符
3. `UrlQuerySanitizer.java` 錯誤地解析 URL 路徑

## Bug 位置

1. **Uri.java** - PathPart.appendDecodedSegment()
2. **UriCodec.java** - appendEncoded()
3. **UrlQuerySanitizer.java** - parseUrl()

## 錯誤代碼 - Uri.java

```java
static PathPart appendDecodedSegment(PathPart oldPart, String newSegment) {
    if (oldPart == null || oldPart == EMPTY) {
        return fromDecoded(newSegment);  // Bug: 缺少前導 /
    }
    
    String oldPath = oldPart.getDecoded();
    // Bug: 沒有組合舊路徑，直接返回新段
    return fromDecoded("/" + newSegment);
}
```

## 錯誤代碼 - UriCodec.java

```java
public static String appendEncoded(StringBuilder builder, String s, 
        String allow, boolean encodeSlash) {
    for (int i = 0; i < s.length(); i++) {
        char c = s.charAt(i);
        // BUG: 總是編碼 '/'，即使 encodeSlash 是 false
        appendHex(builder, c);
    }
}
```

## 錯誤代碼 - UrlQuerySanitizer.java

```java
public void parseUrl(String url) {
    int pathStart = url.indexOf('/');
    if (pathStart >= 0) {
        // BUG: 把路徑當成 query 來解析
        parseQuery(url.substring(pathStart));
    }
}
```

## 修復方案

### Uri.java
```java
static PathPart appendDecodedSegment(PathPart oldPart, String newSegment) {
    if (oldPart == null || oldPart == EMPTY) {
        return fromDecoded("/" + newSegment);
    }
    
    String oldPath = oldPart.getDecoded();
    String newPath = oldPath.endsWith("/") 
        ? oldPath + newSegment 
        : oldPath + "/" + newSegment;
    return fromDecoded(newPath);
}
```

### UriCodec.java
```java
if ((c == '/' && !encodeSlash)) {
    builder.append(c);  // 不編碼 '/'
} else {
    appendHex(builder, c);
}
```

## 呼叫鏈分析

```
Uri.Builder.appendPath("api")
    └── PathPart.appendDecodedSegment(null, "api")
            └── return fromDecoded("/api")
            
Uri.Builder.appendPath("v1")
    └── PathPart.appendDecodedSegment(path="/api", "v1")
            └── return fromDecoded("/v1")  // Bug: 應該是 "/api/v1"
```

## 驗證命令

```bash
atest android.net.cts.UriTest#testBuilderAppendPath
```

## 學習要點

- 累積型 Builder 方法需要保留之前的狀態
- append 語義意味著「追加」而非「替換」
- 編碼邏輯需要正確處理路徑分隔符
