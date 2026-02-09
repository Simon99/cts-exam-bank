# CTS 題庫驗證工作日誌

## 2025-01-XX Medium Q004 驗證

### 驗證環境
- AOSP sandbox: `~/develop_claw/aosp-sandbox-2/`
- lunch target: `aosp_panther-ap2a-userdebug`
- 設備: 27161FDH20031X (Pixel 7)

### Bug 實現位置
Q004 的設計目標是在 BrightnessConfiguration 處理中交換 lux 和 nits 參數順序。

原始 `_answer.md` 描述的位置 `DisplayPowerController.java` 不存在 `setLuxNitsMapping` 方法。經過代碼審查，實際可行的 bug 引入位置是：

**檔案:** `frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java`

**修改位置:** `PhysicalMappingStrategy.computeSpline()` 方法

**原始程式碼:**
```java
private void computeSpline() {
    Pair<float[], float[]> defaultCurve = mConfig.getCurve();
    float[] defaultLux = defaultCurve.first;
    float[] defaultNits = defaultCurve.second;
    ...
}
```

**Bug 版本:**
```java
private void computeSpline() {
    Pair<float[], float[]> defaultCurve = mConfig.getCurve();
    float[] defaultLux = defaultCurve.second;  // BUG: swapped with nits
    float[] defaultNits = defaultCurve.first;  // BUG: swapped with lux
    ...
}
```

### 驗證步驟
1. ✅ 修改 `BrightnessMappingStrategy.java` 引入 bug
2. ✅ 構建 AOSP：成功（約 1.5 分鐘）
3. ✅ 刷機到設備：成功
4. ✅ 構建 CtsDisplayTestCases：成功（約 18 秒）
5. ⚠️ 運行 CtsDisplayTestCases

### 測試結果
運行 CtsDisplayTestCases 後發現：

- **BrightnessTest.testSetGetSimpleCurve** - SKIPPED (AssumptionViolatedException)
- **BrightnessTest.testSetAndGetPerDisplay** - SKIPPED (AssumptionViolatedException)

這些測試被跳過是因為設備不滿足測試前提條件（`assumeTrue` 失敗）。

### 問題分析
在 AOSP (Android Open Source Project) 環境下，Pixel 7 設備可能：
1. 沒有完整的自動亮度配置
2. 缺少 vendor-specific 的亮度曲線配置
3. 需要額外的設備配置才能啟用 BrightnessConfiguration 功能

CTS 測試中的 `assumeTrue` 檢查可能驗證：
- 是否支持自動亮度
- 是否有默認的 BrightnessConfiguration
- 相關權限是否可用

### 結論
**Q004 需要重新設計或標記為"需要特定設備配置"的題目。**

現有的 bug 設計是正確的（交換 lux/nits 參數順序會導致亮度曲線錯誤），但無法在標準 AOSP 環境的 Pixel 7 上通過 CtsDisplayTestCases 驗證。

### 建議
1. **設計替代驗證方法:** 使用單元測試或自定義測試來驗證 BrightnessMappingStrategy 的行為
2. **更新題目元數據:** 標記此題需要具備自動亮度功能的設備配置
3. **考慮替換此題:** 如果無法確保測試環境一致性

### 還原修改
```bash
cd ~/develop_claw/aosp-sandbox-2
git checkout -- frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java
```

---

## 待驗證題目
- [ ] Medium Q005 (VirtualDisplay HDR)
- [ ] Hard Q001-Q005
