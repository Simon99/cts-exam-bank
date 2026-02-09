# Q006 Answer: ETC1 Compressed Texture Decode Failure

## 問題根因
ETC1 紋理處理涉及：
1. `frameworks/native/opengl/libs/ETC1/etc1.cpp` - 核心壓縮/解壓算法
2. `frameworks/base/graphics/java/android/opengl/ETC1.java` - Java API
3. `frameworks/base/graphics/jni/android_opengl_ETC1.cpp` - JNI bridge

問題出在 `etc1.cpp` 的 `etc1_decode_image()` 中，
解壓時 RGB 通道的順序寫反了：寫成了 BGR 而不是 RGB。

## Bug 位置
1. `frameworks/native/opengl/libs/ETC1/etc1.cpp` - decode 函數
2. `frameworks/base/graphics/jni/android_opengl_ETC1.cpp` - JNI 調用
3. `frameworks/base/graphics/java/android/opengl/ETC1Util.java` - 高層 API

## 修復方式
```cpp
// 錯誤的代碼 (etc1.cpp)
void decodeSubblock(etc1_byte* pOut, int r, int g, int b, ...) {
    // ...
    // BUG: 顏色通道順序錯誤
    pOut[outIndex] = clamp(b + modifier);      // Should be r
    pOut[outIndex + 1] = clamp(g + modifier);  // Correct
    pOut[outIndex + 2] = clamp(r + modifier);  // Should be b
}

// 正確的代碼
void decodeSubblock(etc1_byte* pOut, int r, int g, int b, ...) {
    // ...
    pOut[outIndex] = clamp(r + modifier);      // Red
    pOut[outIndex + 1] = clamp(g + modifier);  // Green
    pOut[outIndex + 2] = clamp(b + modifier);  // Blue
}
```

## 調試步驟
1. 創建純色測試紋理進行壓縮/解壓
2. 在 etc1_decode_image 輸入輸出點添加 log
3. 比較原始像素和解壓後的像素
4. 檢查各通道的值

## 相關知識
- ETC1 是 Android 支援的紋理壓縮格式
- RGB vs BGR 順序問題是常見錯誤
- 壓縮紋理可大幅減少 GPU 記憶體使用

## 難度說明
**Hard** - 跨越 Java、JNI、Native 三層，需要理解 ETC1 編碼和顏色格式。
