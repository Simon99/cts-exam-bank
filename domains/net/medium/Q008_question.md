# Q008: Uri.buildUpon().build() 丟失 fragment

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.cts.UriTest#testBuildUponPreservesFragment

junit.framework.AssertionFailedError: 
Expected: "http://example.com/path#section1"
Actual: "http://example.com/path"
    at android.net.cts.UriTest.testBuildUponPreservesFragment(UriTest.java:234)
```

## 測試代碼片段

```java
@Test
public void testBuildUponPreservesFragment() {
    Uri original = Uri.parse("http://example.com/path#section1");
    
    // 驗證原始 URI 有 fragment
    assertEquals("section1", original.getFragment());  // ← 通過
    
    // 使用 buildUpon 複製
    Uri copied = original.buildUpon().build();
    
    // 驗證 fragment 被保留
    assertEquals(original.toString(), copied.toString());  // ← 失敗
    assertEquals("section1", copied.getFragment());        // ← 也失敗
}
```

## 問題描述

使用 `Uri.buildUpon().build()` 創建的新 URI 丟失了原始 URI 的 fragment（`#` 後面的部分）。

`buildUpon()` 應該創建一個包含原 URI 所有部分的 Builder。

## 相關代碼結構

`Uri.java` 中的 StringUri 類：
```java
private static class StringUri extends AbstractHierarchicalUri {
    // ...
    @Override
    public Builder buildUpon() {
        // ... 構建 Builder 時需要複製所有部分
    }
}
```

`Uri.Builder`：
```java
public static final class Builder {
    private String scheme;
    private Part authority;
    private PathPart path;
    private Part query;
    private Part fragment;
    
    public Builder fragment(String fragment) {
        this.fragment = Part.fromDecoded(fragment);
        return this;
    }
}
```

## 任務

1. 找到 `StringUri.buildUpon()` 方法
2. 檢查它如何創建 Builder
3. 找出為什麼 fragment 沒有被複製
4. 修復問題

## 提示

- 涉及文件數：2（Uri.java 內的 StringUri 類和 Builder 類）
- 難度：Medium
- 關鍵字：buildUpon、Builder、fragment、getEncodedFragment
