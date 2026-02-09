# Media-H-Q027 解答

## Root Cause
問題涉及三個檔案的 color aspects 處理：

1. `MediaCodec.cpp` - color aspects 映射錯誤：
```cpp
// 從 VUI 解析的 color primaries 被錯誤映射
// Bug: BT709 被映射成 BT2020
switch (colorPrimaries) {
    case 1:  // BT.709
        aspects.primaries = ColorAspects::PrimariesBT2020;  // 錯誤！
        break;
}
```

2. `ColorConverter.cpp` - transfer function 處理問題。

3. `ColorConverter.h` - 常數定義可能有問題。

## 涉及檔案
- `frameworks/av/media/libstagefright/MediaCodec.cpp`
- `frameworks/av/media/libstagefright/ColorConverter.cpp`
- `frameworks/av/media/libstagefright/include/media/stagefright/ColorConverter.h`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案

## 追蹤路徑
1. CTS log → color aspects 不正確
2. 追蹤 output format → 找到錯誤的 color primaries
3. 追蹤 `MediaCodec::onOutputFormatChanged()` → 找到 mapping 邏輯
4. 追蹤 `ColorConverter` → 確認 enum 對應

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位所有相關檔案 | 30% | 找到全部 3 個檔案 |
| 理解 color aspects 規範 | 20% | 了解 BT.709 vs BT.2020 |
| 理解 root cause | 25% | 能解釋 enum mapping 錯誤 |
| 修復方案正確 | 15% | 恢復正確的映射 |
| 無 side effect | 10% | 確保 HDR 內容仍正確 |

## 常見錯誤方向
- 認為是 decoder 實作問題
- 忽略 VUI 解析和 output format 的轉換
- 只看 Java 層的 color format
