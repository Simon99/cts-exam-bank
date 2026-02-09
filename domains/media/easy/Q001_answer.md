# Media-E-Q001 解答

## Root Cause
`MediaFormat.java` 中 `getInteger()` 方法在處理 `KEY_WIDTH` 和 `KEY_HEIGHT` 時，返回值被交換。

原本：
```java
public int getInteger(@NonNull String name) {
    return ((Integer)mMap.get(name)).intValue();
}
```

被改成（KEY_WIDTH 和 KEY_HEIGHT 的值被交換）：
```java
public int getInteger(@NonNull String name) {
    if (KEY_WIDTH.equals(name)) {
        return ((Integer)mMap.get(KEY_HEIGHT)).intValue();
    } else if (KEY_HEIGHT.equals(name)) {
        return ((Integer)mMap.get(KEY_WIDTH)).intValue();
    }
    return ((Integer)mMap.get(name)).intValue();
}
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaFormat.java`

## Bug Pattern
Pattern A（縱向單點）- 簡單的參數交換

## 追蹤路徑
1. CTS log → `CodecDecoderTest.java:245` 的 `assertEquals` 失敗
2. 查看錯誤訊息 → width 和 height 值完全對調
3. 追蹤 `MediaFormat.getInteger(KEY_WIDTH)` → 發現返回了 height 的值
4. 檢查 `MediaFormat.java` 的 `getInteger()` 方法 → 找到條件判斷邏輯

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaFormat.java |
| 正確定位 bug 位置 | 20% | getInteger() 方法 |
| 理解 root cause | 20% | 能解釋 KEY_WIDTH 和 KEY_HEIGHT 的值被交換 |
| 修復方案正確 | 10% | 移除錯誤的條件判斷 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 native 層 libstagefright 找問題（問題在 Java 層）
- 試圖在 MediaCodec 中找 width/height 設置邏輯
- 檢查 MediaExtractor 的 track format 解析
