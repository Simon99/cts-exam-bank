# Media-M-Q017 解答

## Root Cause
問題出在兩個層級：

1. `MediaFormat.java` 中 CSD buffer 的存取處理：
```java
// setByteBuffer 時錯誤地只儲存 position，不儲存 data
public void setByteBuffer(@NonNull String name, @Nullable ByteBuffer bytes) {
    if (bytes != null) {
        // Bug: 只儲存 position 而非 duplicate buffer
        mMap.put(name, bytes.position());  // 應該是 bytes.duplicate()
    }
}
```

2. `MediaCodec.cpp` 中 native 層 CSD 處理也有相關問題。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaFormat.java`
- `frameworks/av/media/libstagefright/MediaCodec.cpp`

## Bug Pattern
Pattern B（橫向多點）- 影響 2 個檔案

## 追蹤路徑
1. CTS log → csd-0 buffer 大小為 0
2. 追蹤 `MediaFormat.setByteBuffer()` → 發現儲存邏輯錯誤
3. 追蹤 `MediaFormat.getByteBuffer()` → 確認取回邏輯
4. 檢查 native 層 → 確認 JNI 傳遞是否正確

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位主要 bug 檔案 | 30% | 找到 MediaFormat.java |
| 找到次要相關檔案 | 20% | 找到 MediaCodec.cpp |
| 理解 root cause | 25% | 能解釋 ByteBuffer 處理錯誤 |
| 修復方案正確 | 15% | 正確使用 duplicate() |
| 無 side effect | 10% | 確保其他 format keys 不受影響 |

## 常見錯誤方向
- 認為是 decoder 實作問題
- 忽略 ByteBuffer 的 position/limit 語義
- 只看 Java 層不看 native 層
