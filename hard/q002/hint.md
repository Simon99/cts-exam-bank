# Hints for Q002: HDR Type Filtering Logic Error

## Hint 1 - 定位問題範圍
問題出在 `frameworks/base/core/java/android/view/Display.java`，而非 server 端的 DisplayManagerService。專注於客戶端的 HDR 過濾邏輯。

## Hint 2 - 關鍵方法
查看 `getHdrCapabilities()` 方法中的過濾邏輯，特別是它如何判斷一個 HDR 類型是否應該被過濾掉。

## Hint 3 - contains() 方法的問題
`contains()` 方法用於檢查某個 HDR 類型是否在禁用列表中。仔細檢查這個方法的比較邏輯：

```java
private boolean contains(int[] disabledHdrTypes, int hdrType) {
    for (Integer disabledHdrFormat : disabledHdrTypes) {
        if (disabledHdrFormat != hdrType) {  // <-- 這裡的比較對嗎？
            return true;
        }
    }
    return false;
}
```

## Hint 4 - 邏輯分析
考慮以下情況：
- `disabledHdrTypes = [1, 3]` (DOLBY_VISION, HLG)
- 檢查 `hdrType = 2` (HDR10) 是否被禁用

使用 `!=` 的話：
- 第一次迭代：`1 != 2` → true → 返回 true（錯誤！HDR10 不應該被視為禁用）

使用 `==` 的話：
- 第一次迭代：`1 == 2` → false → 繼續
- 第二次迭代：`3 == 2` → false → 繼續
- 迴圈結束 → 返回 false（正確！HDR10 不在禁用列表中）

## 解答
將 `!=` 改回 `==`：
```java
if (disabledHdrFormat == hdrType) {
```
