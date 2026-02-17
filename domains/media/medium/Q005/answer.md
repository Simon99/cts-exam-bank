# Media-M-Q015 解答

## Root Cause
問題涉及 Java 層和 Native 層的 flag 處理：

1. `MediaCodec.java` 中 `dequeueOutputBuffer()` 清除了 EOS flag：
```java
public int dequeueOutputBuffer(BufferInfo info, long timeoutUs) {
    int result = native_dequeueOutputBuffer(info, timeoutUs);
    // Bug: clear EOS flag
    info.flags = info.flags & ~BUFFER_FLAG_END_OF_STREAM;
    return result;
}
```

2. Native 層 `MediaCodec.cpp` 正確設置了 flag，但被 Java 層清除。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodec.java`
- `frameworks/av/media/libstagefright/MediaCodec.cpp`

## Bug Pattern
Pattern B（橫向多點）- Flag 處理不一致

## 追蹤路徑
1. CTS log → EOS flag 未設置
2. 追蹤 `dequeueOutputBuffer()` → 發現 flag 被修改
3. 添加 log 確認 native 層返回的 flag 值
4. 檢查 Java wrapper 的 flag 處理

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 Java 層問題 | 35% | 找到 flag 清除操作 |
| 識別 native 層行為正確 | 15% | 確認 native 層正確設置 flag |
| 理解 root cause | 25% | 能解釋 EOS flag 被清除 |
| 修復方案正確 | 15% | 移除錯誤的 flag 清除 |
| 無 side effect | 10% | 確保其他 flag 不受影響 |

## 常見錯誤方向
- 只看 native 層 MediaCodec
- 檢查 input EOS 設置流程
- 認為是 codec 實作問題
