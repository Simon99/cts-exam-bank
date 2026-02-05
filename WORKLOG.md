# CTS 面試題庫 - 工作日誌

---

## 計劃節點 & 進度追踪

### Phase 1: Pilot — 顯示領域（4 模組 × 3 難度 × 5 題 = 60 題）

| 步驟 | 說明 | 狀態 | 預計完成 |
|------|------|------|----------|
| 1.1 | 環境準備：沙盒拷貝 × 2 | 🔄 進行中（sandbox-1 拷貝中） | TBD |
| 1.2 | 題庫架構設計 & 建置 | ✅ 方案已提出 | 待確認 |
| 1.3 | 源碼分析：4 模組調用鏈地圖 | ✅ 完成 | - |
| 1.4 | 題目設計：CtsDisplayTestCases (15題) | 🔄 初稿完成，待修正難度定義 | - |
| 1.5 | 題目設計：CtsColorModeTestCases (15題) | ⬜ 未開始 | - |
| 1.6 | 題目設計：CtsThemeDeviceTestCases (15題) | ⬜ 未開始 | - |
| 1.7 | 題目設計：CtsBootDisplayModeTestCases (15題) | ⬜ 未開始 | - |
| 1.8 | 實作第一題：埋 bug → build → flash → CTS fail 驗證 | ⬜ 未開始 | - |
| 1.9 | 流程驗證通過 → 批量實作 | ⬜ 未開始 | - |

### Phase 2: 全面鋪開（其餘 4 領域）
- ⬜ Framework 核心 (8 模組)
- ⬜ 圖形 (5 模組)
- ⬜ 多媒體 (7 模組)
- ⬜ 相機 (3 模組)

---

## 2026-02-05

### 11:00 專案啟動
- 確認環境：AOSP 源碼、Pixel 7、CTS 工具、磁碟空間
- 確認五大領域：Framework 核心、圖形、顯示、多媒體、相機
- 決定先以「顯示」領域作為 pilot 跑通流程

### 11:01 開始拷貝 AOSP 沙盒
- `cp -a ~/aosp-panther/. ~/develop/aosp-sandbox-1/`（進行中）
- 第二份等第一份完成後開始
- 完整拷貝 189G × 2，預計佔用 378G

### 11:04 顯示領域模組分析
分析了 4 個模組的 CTS 測試內容和對應源碼：

**CtsDisplayTestCases**
- 測試檔案：DisplayTest, BrightnessTest, VirtualDisplayTest, DefaultDisplayModeTest, HdrConversion*, DisplayEventTest, DisplayManagerTest
- 約 45+ 測試方法
- 對應源碼：`frameworks/base/services/core/.../server/display/`
- 主要類別：DisplayManagerService, DisplayPowerController, BrightnessTracker, DisplayDeviceConfig 等

**CtsColorModeTestCases**
- 測試檔案：DefaultColorModeTest, WideColorModeTest, AttributeWideColorModeTest
- 3 個測試方法，都是 testDefaultColorMode
- 對應源碼：色彩管理相關，跨 framework + native (SurfaceFlinger)

**CtsThemeDeviceTestCases**
- 測試檔案：ThemeRebaseTest, WatchPercentageScreenDimenTest
- 4 個測試方法
- 對應源碼：`frameworks/base/core/` 主題/資源系統

**CtsBootDisplayModeTestCases**
- Host-side 測試（jar 而非 apk）
- 2 個測試：testGetBootDisplayMode, testClearBootDisplayMode
- 涉及 reboot 驗證，對應 DisplayManagerService + DisplayManagerShellCommand

### 11:09 重要決策記錄
- 測試方法數量 ≠ 可出題數量。同一個 fail 現象可由不同位置的 bug 造成
- 出題重點是源碼中可以埋 bug 的位置，不是測試項數

### 11:10 源碼深入分析

**調用鏈地圖（顯示領域）**

核心架構層級（從上到下）：
```
CTS 測試 → Display API (android.view.Display)
  → DisplayManager → DisplayManagerService (5148行)
    → LogicalDisplay (999行) → LogicalDisplayMapper
      → DisplayDevice (406行) → DisplayDeviceInfo
        → SurfaceFlinger (native 層)
```

**CtsDisplayTestCases 關鍵調用鏈：**
1. 亮度相關：DisplayManager → DisplayManagerService → DisplayPowerController (3284行) → BrightnessTracker (1216行) → AutomaticBrightnessController
2. 模式切換：Display.getSupportedModes → DisplayManagerService → LogicalDisplay → DisplayDevice → DisplayModeDirector
3. HDR：Display.getHdrCapabilities → DisplayManagerService → DisplayDevice → SurfaceFlinger
4. 色域：Display.isWideColorGamut/getPreferredWideGamutColorSpace → DisplayManagerService.getPreferredWideGamutColorSpaceIdInternal
5. VirtualDisplay：DisplayManagerService → VirtualDisplayAdapter → DisplayDevice

**CtsColorModeTestCases 關鍵調用鏈：**
1. ActivityInfo.colorMode → PackageManager 解析 manifest
2. Window.getAttributes().getColorMode() → PhoneWindow → WindowManager.LayoutParams
3. Window.isWideColorGamut() → 看 colorMode + Display.isWideColorGamut()
4. 色彩管理服務：ColorDisplayService (2037行) → DisplayTransformManager → TintController 子類們

**CtsThemeDeviceTestCases 關鍵調用鏈：**
1. Theme.applyStyle → ResourcesImpl → AssetManager
2. Theme.rebase → Resources.setImpl → ThemeImpl 更新
3. Resources.updateConfiguration → ResourcesManager cache → ResourcesKey
4. Theme.resolveAttribute → 查 style/overlay 層級

**CtsBootDisplayModeTestCases 關鍵調用鏈：**
1. setUserPreferredDisplayMode → DisplayManagerService.setUserPreferredDisplayModeInternal → DisplayDevice.setUserPreferredDisplayModeLocked → PersistentDataStore
2. clearBootDisplayMode → setUserPreferredDisplayModeInternal(null)
3. getActiveDisplayModeAtStart → DisplayManagerShellCommand → DisplayManagerService.getActiveDisplayModeAtStart → DisplayDevice.getActiveDisplayModeAtStartLocked
4. reboot 驗證：device.reboot() → "cmd display get-active-display-mode-at-start 0"

### 11:14 重要修正：難度定義澄清
老大指出：**難度 ≠ bug 層級深淺**
- 難度是「牽連多少個檔案」「追踪路徑多複雜」
- 初級：bug 在哪裡，log 就指向哪裡（不管深淺）
- 中級：log 指向的地方不是 root cause，需要加 log 追踪（牽涉 ~2 檔案）
- 高級：調用鏈跨 3+ 檔案（A→B→C），log 在 A，問題在 C

→ 需要重新審視 DESIGN.md，確保題目設計符合此定義
→ 例如：一個在 SurfaceFlinger (native) 層的 bug，如果 CTS log 直接指出了問題位置，那也是初級題

### 11:15 CtsDisplayTestCases 15 題初稿完成
- easy/DESIGN.md, medium/DESIGN.md, hard/DESIGN.md 已寫入
- 需要根據修正後的難度定義 review 和調整

### 待辦
- [ ] 等沙盒拷貝完成
- [ ] 深入分析每個模組的源碼調用鏈（為埋 bug 做準備）
- [ ] 設計題庫目錄架構並建置
- [ ] 設計 pilot 題目（顯示 × 4 模組 × 3 難度 × 5 題 = 60 題）
- [ ] 跑通一題完整流程：埋 bug → build → flash → CTS fail → 驗證
