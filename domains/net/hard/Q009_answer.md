# Q009 解答：Uri.getQueryParameterNames() 返回重複的參數名

## 問題根因

問題涉及三個檔案的交互：
1. `Uri.java` 使用 `ArrayList` 而非 `Set` 收集參數名
2. `UriCodec.java` 提取參數名時分割邏輯錯誤
3. `UrlQuerySanitizer.java` 的 `getParameterSet()` 也有類似問題

## Bug 位置

1. **Uri.java** - getQueryParameterNames()
2. **UriCodec.java** - extractParameterNames()
3. **UrlQuerySanitizer.java** - getParameterSet()

## 錯誤代碼 - Uri.java

```java
public Set<String> getQueryParameterNames() {
    // Bug: 使用 ArrayList 而不是 LinkedHashSet
    ArrayList<String> names = new ArrayList<String>();
    // ... 解析邏輯 ...
    return Collections.unmodifiableSet(new LinkedHashSet<>(names));
}
```

## 錯誤代碼 - UriCodec.java

```java
public static List<String> extractParameterNames(String query) {
    List<String> names = new ArrayList<>();
    // BUG: 錯誤的分割字符
    for (String param : query.split("\\?")) {  // 應該是 "&"
        names.add(param);  // 沒有提取參數名
    }
    return names;
}
```

## 錯誤代碼 - UrlQuerySanitizer.java

```java
public Set<String> getParameterSet() {
    // BUG: 使用 ArrayList 允許重複
    ArrayList<String> list = new ArrayList<>();
    for (ParameterValuePair pair : mEntriesList) {
        list.add(pair.mParameter);
    }
    return new HashSet<>(list);  // 順序丟失
}
```

## 修復方案

### Uri.java
```java
public Set<String> getQueryParameterNames() {
    LinkedHashSet<String> names = new LinkedHashSet<String>();
    // ... 解析邏輯 ...
    return Collections.unmodifiableSet(names);
}
```

### UriCodec.java
```java
public static List<String> extractParameterNames(String query) {
    List<String> names = new ArrayList<>();
    for (String param : query.split("&")) {
        int eqIndex = param.indexOf('=');
        String name = eqIndex >= 0 ? param.substring(0, eqIndex) : param;
        names.add(decode(name, ...));
    }
    return names;
}
```

### UrlQuerySanitizer.java
```java
public Set<String> getParameterSet() {
    LinkedHashSet<String> set = new LinkedHashSet<>();
    for (ParameterValuePair pair : mEntriesList) {
        set.add(pair.mParameter);
    }
    return Collections.unmodifiableSet(set);
}
```

## Set vs List 行為

```java
// ArrayList: ["a", "b", "a"] - 允許重複
// LinkedHashSet: ["a", "b"] - 自動去重且保持順序
```

## 驗證命令

```bash
atest android.net.cts.UriTest#testGetQueryParameterNames
```

## 學習要點

- 需要唯一性時從一開始就用 Set
- LinkedHashSet 保持插入順序且去重
- 多個檔案的相同邏輯需要一致處理
