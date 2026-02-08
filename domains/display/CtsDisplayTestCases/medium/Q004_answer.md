# M-Q004: 答案

## Bug 位置

**檔案:** `frameworks/base/services/core/java/com/android/server/display/DisplayPowerController.java`

**問題:** `setBrightnessConfiguration()` 方法中，保存曲線時把 lux 和 nits 陣列順序弄反

## 根因分析

在 `DisplayPowerController.setBrightnessConfiguration()` 中，有一段處理曲線數據的邏輯：

### 正確程式碼：
```java
public void setBrightnessConfiguration(BrightnessConfiguration config) {
    // ...
    float[] lux = config.getLuxValues();
    float[] nits = config.getNitsValues();
    
    mBrightnessMapper.setLuxNitsMapping(lux, nits);  // 正確順序
    // ...
}
```

### Bug 版本：
```java
public void setBrightnessConfiguration(BrightnessConfiguration config) {
    // ...
    float[] lux = config.getLuxValues();
    float[] nits = config.getNitsValues();
    
    mBrightnessMapper.setLuxNitsMapping(nits, lux);  // [BUG] 參數順序反了
    // ...
}
```

### 邏輯分析

假設設定的曲線：
- lux = [0.0, 100.0, 1000.0]（環境光照度）
- nits = [10.0, 200.0, 500.0]（對應亮度值）

**正確邏輯：**
- 存入：lux → lux slot, nits → nits slot
- 取出：返回原始曲線

**Bug 邏輯：**
- 存入：nits → lux slot, lux → nits slot（對調了）
- 取出：返回對調的曲線

所以 get 時看到 lux=[10.0, 200.0, 500.0]（其實是原本的 nits 值）。

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayPowerController.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayPowerController.java
@@ -xxx,7 +xxx,7 @@ public class DisplayPowerController {
     public void setBrightnessConfiguration(BrightnessConfiguration config) {
         float[] lux = config.getLuxValues();
         float[] nits = config.getNitsValues();
-        mBrightnessMapper.setLuxNitsMapping(nits, lux);
+        mBrightnessMapper.setLuxNitsMapping(lux, nits);
         // ...
     }
 }
```

## 診斷技巧

1. **對比 set/get 的值** - 發現數據對調而不是丟失或損壞
2. **在 set 路徑加 log** - 確認傳入的參數值
3. **在 get 路徑加 log** - 確認取出的值，發現對調發生在存入時
4. **檢查方法簽名** - `setLuxNitsMapping(float[] lux, float[] nits)` 參數順序

## 評分標準

| 項目 | 分數 |
|------|------|
| 理解 set/get 不一致問題 | 15% |
| 找到 DisplayPowerController | 25% |
| 定位到 setBrightnessConfiguration | 30% |
| 識別出參數順序錯誤 | 30% |
