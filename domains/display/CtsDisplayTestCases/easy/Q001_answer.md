# Display-E-Q001 解答

## Root Cause
`Display.java` 第 1263 行，`HdrCapabilities` 建構子呼叫時，`mMinLuminance` 和 `mMaxAverageLuminance` 參數順序被交換。

原本：
```java
new HdrCapabilities(supportedHdrTypes,
    mDisplayInfo.hdrCapabilities.mMaxLuminance,
    mDisplayInfo.hdrCapabilities.mMaxAverageLuminance,  // 第3參數
    mDisplayInfo.hdrCapabilities.mMinLuminance);         // 第4參數
```

被改成：
```java
new HdrCapabilities(supportedHdrTypes,
    mDisplayInfo.hdrCapabilities.mMaxLuminance,
    mDisplayInfo.hdrCapabilities.mMinLuminance,          // 交換
    mDisplayInfo.hdrCapabilities.mMaxAverageLuminance);   // 交換
```

## 涉及檔案
- `frameworks/base/core/java/android/view/Display.java`（第 1263 行）

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → `DisplayTest.java:369` 的 `assertTrue` 失敗
2. 查看 CTS 測試源碼 → 驗證 `minLuminance <= maxAverageLuminance`
3. 追蹤 `Display.getHdrCapabilities()` → 看到建構子參數順序異常
4. 比對 `HdrCapabilities` 建構子的參數定義 → 確認第 3、4 參數被交換

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 Display.java |
| 正確定位 bug 位置 | 20% | 第 1263 行參數順序 |
| 理解 root cause | 20% | 能解釋 minLuminance 和 maxAverageLuminance 交換導致斷言失敗 |
| 修復方案正確 | 10% | 交換回正確順序 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 DisplayDeviceInfo 或 LogicalDisplay 找問題（往底層找，但問題在 client 端）
- 試圖在 SurfaceFlinger 層找 HDR 相關邏輯（over-engineering）
- 沒有看 HdrCapabilities 建構子的參數定義，只看呼叫端
