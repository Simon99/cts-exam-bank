# Q007 答案 [Hard]：GNSS Antenna Info Coordinates Swapped

## Bug 位置

### Bug: GnssAntennaInfoProvider.java - convertPhaseCenterOffset()
座標轉換時 X 和 Y 沒有正確交換：

```java
// 錯誤代碼
double androidX = halX;  // 應該是 halY
double androidY = halY;  // 應該是 halX
```

## 座標系統說明

### HAL 座標系統（車輛座標）
- X = Forward（前方）
- Y = Right（右方）
- Z = Up（上方）

### Android 座標系統（螢幕座標）
- X = Right（右方）
- Y = Forward（前方）
- Z = Up（上方）

### 正確的轉換
```java
double androidX = halY;  // HAL 的 Y (Right) → Android 的 X
double androidY = halX;  // HAL 的 X (Forward) → Android 的 Y
double androidZ = halZ;  // Z 不變
```

## 完整呼叫鏈

```
GNSS HAL (JNI callback)
    → GnssNative.reportAntennaInfo()
        → GnssAntennaInfoProvider.onReportAntennaInfo()
            → convertPhaseCenterOffset() ← BUG: X/Y 未交換
                → 建立 GnssAntennaInfo
                    → 傳遞給 listeners
```

## 修復方案

```java
private GnssAntennaInfo.PhaseCenterOffset convertPhaseCenterOffset(
        double halX, double halY, double halZ,
        double halXUnc, double halYUnc, double halZUnc) {
    // Correct coordinate conversion
    double androidX = halY;  // HAL Y → Android X
    double androidY = halX;  // HAL X → Android Y
    double androidZ = halZ;
    
    double androidXUnc = halYUnc;  // 不確定度也要交換
    double androidYUnc = halXUnc;
    double androidZUnc = halZUnc;
    
    return new GnssAntennaInfo.PhaseCenterOffset(
        androidX, androidXUnc,
        androidY, androidYUnc,
        androidZ, androidZUnc);
}
```

## 教學重點

1. **座標系統轉換**：不同系統使用不同的座標定義
2. **HAL 到 Framework**：數據轉換是常見的 bug 來源
3. **高精度應用**：天線偏移對 RTK/PPP 等高精度定位很重要
4. **驗證方法**：座標交換錯誤會導致 X/Y 值互換
