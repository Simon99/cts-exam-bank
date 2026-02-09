# M-Q007: HDR 類型過濾邏輯錯誤 - 答案

## Bug 分析

此題涉及兩個檔案中的協同 bug，導致 HDR 類型過濾完全失效。

### Bug 1: Display.java - contains() 方法條件反轉

**位置:** `core/java/android/view/Display.java`

```java
private boolean contains(int[] disabledHdrTypes, int hdrType) {
    for (Integer disabledHdrFormat : disabledHdrTypes) {
        if (disabledHdrFormat != hdrType) {  // [BUG] 應該是 ==
            return true;
        }
    }
    return false;
}
```

**問題:** 
- 條件 `!=` 應該是 `==`
- 這導致只要陣列中有任何一個元素與 hdrType 不同，就返回 true
- 結果：幾乎所有 HDR 類型都被認為是"被禁用的"

### Bug 2: DisplayInfo.java - 反序列化順序錯誤

**位置:** `core/java/android/view/DisplayInfo.java`

```java
for (int i = 0; i < numUserDisabledFormats; i++) {
    userDisabledHdrTypes[numUserDisabledFormats - 1 - i] = source.readInt();  // [BUG] 反向寫入
}
```

**問題:**
- 讀取時以反向順序填充陣列
- 如果禁用列表是 [1, 3]，讀取後變成 [3, 1]
- 雖然看起來影響不大，但與 Bug 1 結合時會產生更複雜的錯誤行為

## 修復方案

### 修復 1: Display.java

```java
private boolean contains(int[] disabledHdrTypes, int hdrType) {
    for (Integer disabledHdrFormat : disabledHdrTypes) {
        if (disabledHdrFormat == hdrType) {  // 修復：使用 ==
            return true;
        }
    }
    return false;
}
```

### 修復 2: DisplayInfo.java

```java
for (int i = 0; i < numUserDisabledFormats; i++) {
    userDisabledHdrTypes[i] = source.readInt();  // 修復：正常順序
}
```

## 驗證

```bash
atest android.display.cts.DisplayTest#testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes
```

## 學習重點

1. **邏輯運算符的重要性**: `==` vs `!=` 的差異會完全改變程式行為
2. **序列化/反序列化一致性**: 讀取順序必須與寫入順序完全一致
3. **跨檔案 bug 追蹤**: 一個功能的 bug 可能分布在呼叫鏈的多個位置
4. **HDR 過濾機制**: 了解 userDisabledHdrTypes 如何與 supportedHdrTypes 配合工作

## 難度

**Medium** - 需要理解 HDR 過濾邏輯和 Parcel 序列化機制
