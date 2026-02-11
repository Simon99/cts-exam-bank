# CTS 測試失敗 — MediaCodec Async Callback Buffer 狀態錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecDecoderTest#testAsyncCallback`

## CTS 失敗 Log
```
junit.framework.AssertionError: Output buffer state inconsistency in async mode
Buffer index 3 was released but onOutputBufferAvailable still reports it as pending

Test sequence:
1. Configured decoder in async mode (setCallback)
2. Received onOutputBufferAvailable(index=3)
3. Called releaseOutputBuffer(3, false)
4. Expected: buffer 3 returned to codec
5. Actual: Next onOutputBufferAvailable still returns index=3

Buffer tracking:
  Available buffers reported: [0, 1, 2, 3, 3, 3, ...]  (3 repeating)
  Expected pattern: [0, 1, 2, 3, 0, 1, 2, 3, ...]
  
  at org.junit.Assert.fail(Assert.java:87)
  at android.mediav2.cts.CodecDecoderTest.validateAsyncBufferCycle(CodecDecoderTest.java:1198)
  at android.mediav2.cts.CodecDecoderTest.testAsyncCallback(CodecDecoderTest.java:1245)
```

## 額外資訊
- 問題只在 async callback mode 出現，sync mode 正常
- buffer index 會重複被報告為 available
- 最終導致 buffer 耗盡，decode 停滯

## Async Mode 背景
```java
codec.setCallback(new MediaCodec.Callback() {
    @Override
    public void onOutputBufferAvailable(MediaCodec mc, int index, BufferInfo info) {
        // Process output
        mc.releaseOutputBuffer(index, false);  // Return buffer to codec
    }
});
```

## 任務
1. 定位造成 buffer 狀態追蹤錯誤的原始碼修改
2. 說明 async callback 中 buffer 生命週期管理
3. 提出修復方案並驗證 CTS 通過

## 提示
需要追蹤 Native MediaCodec → Java MediaCodec callback → buffer 狀態機的完整流程。
