# CTS 題目：HDR 轉換模式設定邏輯錯誤

## 難度：Medium
## 預計時間：25 分鐘

---

## 背景

Android 的 `DisplayManagerService` 負責管理 HDR（High Dynamic Range）輸出轉換模式。系統支援三種轉換模式：

1. **HDR_CONVERSION_SYSTEM**：系統自動選擇最佳 HDR 輸出類型
2. **HDR_CONVERSION_PASSTHROUGH**：直通模式，不進行轉換
3. **HDR_CONVERSION_FORCE**：強制使用指定的 HDR 輸出類型

應用程式可以透過 `WindowManager.LayoutParams` 覆蓋（override）系統的 HDR 轉換設定，此時 `mOverrideHdrConversionMode` 會被設定為非 null 值。

## 問題描述

QA 團隊報告以下異常行為：

1. **CTS 測試失敗**：`HdrConversionEnabledTest#testSetHdrConversionMode` 測試失敗
2. **用戶反饋**：當應用程式覆蓋 HDR 設定時，系統行為與預期相反
3. **症狀**：
   - 當沒有應用覆蓋時，HDR 強制 SDR 模式無法正確切換到 passthrough
   - 當有應用覆蓋時，覆蓋設定被忽略，使用了原始設定

## 相關代碼

問題出在 `DisplayManagerService.java` 的 `setHdrConversionModeInternal()` 方法中。

```java
// 檔案路徑: frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
// 方法: setHdrConversionModeInternal()
// 行號: 約 2413-2455

void setHdrConversionModeInternal(HdrConversionMode hdrConversionMode) {
    if (!mInjector.getHdrOutputConversionSupport()) {
        return;
    }
    int[] autoHdrOutputTypes = null;
    synchronized (mSyncRoot) {
        // ... 參數驗證 ...
        
        mHdrConversionMode = hdrConversionMode;
        storeHdrConversionModeLocked(mHdrConversionMode);

        // 自動模式處理
        if (hdrConversionMode.getConversionMode() == HdrConversionMode.HDR_CONVERSION_SYSTEM) {
            autoHdrOutputTypes = getEnabledAutoHdrTypesLocked();
        }

        int conversionMode = hdrConversionMode.getConversionMode();
        int preferredHdrType = hdrConversionMode.getPreferredHdrOutputType();
        
        // 關鍵邏輯：處理應用覆蓋設定
        if (/* 某個條件 */) {
            // 正常模式處理
            if (conversionMode == HdrConversionMode.HDR_CONVERSION_FORCE
                    && preferredHdrType == Display.HdrCapabilities.HDR_TYPE_INVALID) {
                conversionMode = HdrConversionMode.HDR_CONVERSION_PASSTHROUGH;
            }
        } else {
            // 使用覆蓋設定
            conversionMode = mOverrideHdrConversionMode.getConversionMode();
            preferredHdrType = mOverrideHdrConversionMode.getPreferredHdrOutputType();
            autoHdrOutputTypes = null;
        }
        
        mSystemPreferredHdrOutputType = mInjector.setHdrConversionMode(
                conversionMode, preferredHdrType, autoHdrOutputTypes);
    }
}
```

## 任務

1. 找出導致上述症狀的 bug
2. 解釋為什麼這個 bug 會導致 CTS 測試失敗
3. 提供修復方案

## 提示

- 仔細閱讀註解說明的預期行為
- 思考 `mOverrideHdrConversionMode` 為 null 和非 null 時應該執行哪個分支
- 條件判斷的正負邏輯是否正確？

## 驗證 CTS 測試

```bash
atest android.hardware.display.cts.HdrConversionEnabledTest#testSetHdrConversionMode
```
