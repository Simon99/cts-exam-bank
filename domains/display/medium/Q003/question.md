# CTS 除錯題目：Display Brightness Mapping Bug

## 題目背景

你是 Android Display 團隊的工程師。QA 回報了以下問題：

**Bug Report #DIS-2024-0893**  
**嚴重程度**: Medium  
**影響範圍**: 自動亮度調整功能

**問題描述**:  
用戶回報啟用「自動亮度」和「顯示白平衡」功能後，滑動亮度滑桿時，實際亮度變化與預期的亮度曲線不符。特別是在白平衡調整生效的情況下，亮度似乎完全忽略了白平衡的補償計算。

**重現步驟**:
1. 開啟設定 > 顯示 > 自動亮度
2. 開啟設定 > 顯示 > 顯示白平衡（或色彩適應）
3. 在不同環境光條件下調整亮度滑桿
4. 觀察亮度變化是否符合預期曲線

**預期行為**: 亮度調整應該考慮白平衡控制器的補償值，呈現平滑的亮度曲線。

**實際行為**: 白平衡補償似乎被忽略，亮度曲線不正確。

---

## CTS 測試失敗資訊

```
FAIL: android.hardware.display.cts.BrightnessTest#testSliderEventsReflectCurves

java.lang.AssertionError: Brightness curve mismatch when white balance adjustment is active.
Expected brightness at lux=500 with white balance: 0.42
Actual brightness: 0.38
Delta exceeds tolerance of 0.01

    at android.hardware.display.cts.BrightnessTest.testSliderEventsReflectCurves(BrightnessTest.java:287)
```

---

## 相關檔案

請檢查以下檔案，找出導致 CTS 測試失敗的根本原因：

- `frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java`

重點關注 `PhysicalMappingStrategy` 內部類別的 `getBrightness()` 方法實作。

---

## 任務

1. **分析程式碼**：找出導致白平衡補償失效的 bug
2. **解釋問題**：說明為什麼這個 bug 會導致上述 CTS 測試失敗
3. **提供修復**：給出正確的程式碼修復方案

---

## 評分標準

- **定位準確** (40%): 正確指出有問題的程式碼位置
- **分析完整** (30%): 清楚解釋 bug 的成因與影響
- **修復正確** (30%): 提供正確且符合規範的修復方案
