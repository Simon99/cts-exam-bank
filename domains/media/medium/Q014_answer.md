# Media-M-Q014 解答

## Root Cause
問題涉及 Java 層和 Native 層的 timestamp 傳遞：

1. `MediaMuxer.java` 中 `writeSampleData()` 使用靜態變數記住第一個 PTS：
```java
private long mFirstPts = -1;

public void writeSampleData(int trackIndex, ByteBuffer byteBuf, BufferInfo bufferInfo) {
    if (mFirstPts < 0) {
        mFirstPts = bufferInfo.presentationTimeUs;
    }
    // Bug: always use first PTS instead of current
    nativeWriteSampleData(trackIndex, byteBuf, bufferInfo.offset, 
                          bufferInfo.size, mFirstPts, bufferInfo.flags);
}
```

2. Native 層 `MediaMuxer.cpp` 直接使用傳入的錯誤 timestamp。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaMuxer.java`
- `frameworks/av/media/libstagefright/MediaMuxer.cpp`

## Bug Pattern
Pattern B（橫向多點）- 狀態變數濫用導致問題

## 追蹤路徑
1. CTS log → 所有 PTS 都相同
2. 追蹤 `writeSampleData()` → 發現使用靜態 PTS
3. 檢查 native 層 → 確認直接使用傳入值
4. 添加 log 驗證 Java 層傳遞的 PTS

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 Java 層問題 | 35% | 找到 mFirstPts 的濫用 |
| 識別 native 層關聯 | 15% | 追蹤 JNI 調用 |
| 理解 root cause | 25% | 能解釋 PTS 被固定的原因 |
| 修復方案正確 | 15% | 使用正確的 presentationTimeUs |
| 無 side effect | 10% | 確保多 track 寫入正常 |

## 常見錯誤方向
- 只看 native 層 MPEG4Writer
- 認為是 extractor 解析問題
- 去檢查 track 格式設置
