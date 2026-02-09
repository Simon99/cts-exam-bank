# Q002 v3 驗證報告

**日期:** 2025-02-09  
**設備:** 2B231FDH200B4Z (Pixel 7)  
**Sandbox:** aosp-sandbox-2  
**驗證者:** Claude (subagent)

## 驗證結果：✅ 成功

### 測試結果

#### Test 1: testGetSupportedModesOnDefaultDisplay
- **結果:** FAIL ✅ (預期行為)
- **錯誤訊息:**
```
java.lang.AssertionError: Could not find alternative display mode with refresh rate 90.0 
for {id=1, width=1080, height=2400, fps=60.0, vsync=60.0, alternativeRefreshRates=[90.0], supportedHdrTypes=[2, 3, 4]}. 
All supported modes are [{id=1, width=1080, height=2400, fps=60.0, vsync=60.0, alternativeRefreshRates=[90.0], supportedHdrTypes=[2, 3, 4]}]. 
Actual: -1
```

#### Test 2: testActiveModeIsSupportedModesOnDefaultDisplay
- **結果:** FAIL ✅ (預期行為)
- **錯誤訊息:**
```
java.lang.AssertionError
at android.display.cts.DisplayTest.testActiveModeIsSupportedModesOnDefaultDisplay(DisplayTest.java:942)
```

### Bug 行為分析

1. **正常情況:** 設備有 2 個 modes (60Hz 和 90Hz)
2. **Bug 效果:** `Display.getSupportedModes()` 只返回 1 個 mode (60Hz)
3. **原因:** `Arrays.copyOf(modes, Math.max(1, modes.length-1))` 截斷了最後一個 mode

### 測試失敗機制

- Mode 1 (60Hz) 的 `alternativeRefreshRates` 指向 90Hz
- 但 `getSupportedModes()` 只返回 `[{id=1, fps=60.0}]`
- 測試檢查每個 mode 的 alternativeRefreshRates 是否都能在 supportedModes 中找到
- 找不到 90Hz mode → 測試失敗

### 驗證流程

1. ✅ 編譯 framework-minus-apex (01:12)
2. ✅ Sync 到設備 (106 files pushed)
3. ✅ 設備重啟並就緒
4. ✅ 執行 CTS 測試 - 兩個測試都失敗

### 結論

Q002 v3 patch 驗證成功：
- Bug 成功導致 CTS 測試失敗
- 設備正常開機 (bootSafe: true)
- 錯誤訊息符合預期 pattern
- 適合作為面試題使用

### 更新建議

更新 Q002_meta.json:
- `verified: true`
- `verifiedDate: "2025-02-09"`
- `verifiedDevice: "Pixel 7 (2B231FDH200B4Z)"`
