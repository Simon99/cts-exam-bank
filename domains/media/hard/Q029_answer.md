# Media-H-Q029 解答

## Root Cause
問題出在三個檔案的 async callback buffer 狀態管理：

1. `MediaCodec.cpp` - output buffer available callback 狀態更新：
```cpp
// Bug: 發送 callback 前沒有正確標記 buffer 為 "pending"
// 導致同一個 buffer index 被重複報告
void MediaCodec::onOutputBufferAvailable() {
    // Missing: mOutputBuffersPending.insert(index);
    // 直接發送 callback，沒有追蹤狀態
}
```

2. `MediaCodec.java` - buffer release 後狀態清理：
```java
// Bug: releaseOutputBuffer 後沒有從追蹤 set 移除
// 導致 native 層認為 buffer 仍被 Java 持有
private void releaseOutputBufferInternal(...) {
    // Missing: mDequeuedOutputBuffers.remove(index);
}
```

3. `ACodec.cpp` - buffer 回收後重新通知：
```cpp
// Bug: buffer 回收邏輯錯誤，導致已回收的 buffer 再次觸發通知
void ACodec::onOutputBufferDrained() {
    // 應該等 buffer 真正返回 codec 後才標記為 available
    // 但這裡過早發送 available 通知
}
```

## Buffer 生命週期 (Async Mode)

正確流程：
```
1. Codec produces output → Native marks buffer OWNED_BY_CLIENT
2. Native sends CB_OUTPUT_AVAILABLE to Java
3. Java receives onOutputBufferAvailable(index)
4. Java calls releaseOutputBuffer(index)
5. Native receives release → marks buffer OWNED_BY_CODEC
6. Buffer returns to codec pool → ready for reuse
7. Codec produces new output → goto step 1
```

Bug 導致的錯誤流程：
```
1. Codec produces output
2. Native sends CB_OUTPUT_AVAILABLE(index=3) ← 沒有標記狀態
3. Java receives callback
4. Java releases buffer
5. Native 狀態沒更新 → 同一個 index 再次被報告
6. 無限重複 index=3
```

## 涉及檔案
- `frameworks/av/media/libstagefright/MediaCodec.cpp`
- `frameworks/base/media/java/android/media/MediaCodec.java`
- `frameworks/av/media/libstagefright/ACodec.cpp`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案，Native ↔ Java 的狀態同步問題

## 追蹤路徑
1. CTS log → buffer index 重複
2. 檢查 Java callback handler → 確認 callback 被正常調用
3. 追蹤 native MediaCodec → 發現 onOutputBufferAvailable 狀態問題
4. 追蹤 buffer ownership → 發現 release 後狀態未更新
5. 追蹤 ACodec → 發現提前觸發 available 通知

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 理解 async callback 機制 | 20% | 知道 setCallback 的工作原理 |
| 正確定位所有相關檔案 | 25% | 找到全部 3 個檔案 |
| 理解 buffer ownership 狀態機 | 25% | OWNED_BY_CLIENT vs OWNED_BY_CODEC |
| 修復方案正確 | 20% | 正確維護狀態追蹤 |
| 考慮 race condition | 10% | 知道這是多線程問題 |

## 常見錯誤方向
- 只看 Java 層不追蹤 Native
- 忽略 callback handler 的異步特性
- 認為是 sync mode 的問題
- 沒有理解 buffer ownership 轉移
