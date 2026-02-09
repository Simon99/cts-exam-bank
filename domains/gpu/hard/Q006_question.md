# Q006: ETC1 Compressed Texture Decode Failure

## CTS Test
`android.opengl.cts.CompressedTextureTest#testETC1Compression`

## Failure Log
```
junit.framework.AssertionFailedError: ETC1 texture decode produced wrong colors

Original image: solid red (255, 0, 0)
After ETC1 encode/decode: (0, 255, 0) - showing green instead

ETC1 decompression appears to have swapped color channels

Reference checksum: 0xABCD1234
Actual checksum: 0x5678EFGH

at android.opengl.cts.CompressedTextureTest.testETC1Compression(CompressedTextureTest.java:178)
```

## 現象描述
ETC1 壓縮紋理解壓後顏色錯誤。紅色變成綠色，
表明顏色通道被交換了。這影響所有使用 ETC1 的遊戲和應用。

## 提示
- ETC1 壓縮/解壓在 `libs/ETC1/` 中實現
- 涉及 native 代碼和 Java wrapper
- 可能是 RGB 順序的問題
- 需要追蹤從 Java → JNI → native 的資料流
