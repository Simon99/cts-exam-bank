# CTS 面試題庫 - 工作日誌

---

## 計劃節點 & 進度追踪

### Phase 1: Pilot — 顯示領域（4 模組 × 3 難度 × 5 題 = 60 題）

| 步驟 | 說明 | 狀態 | 預計完成 |
|------|------|------|----------|
| 1.1 | 環境準備：沙盒拷貝 × 2 | 🔄 sandbox-1 ✅ / sandbox-2 拷貝中 | - |
| 1.2 | 題庫架構設計 & 建置 | ✅ 方案已提出 | 待確認 |
| 1.3 | 源碼分析：4 模組調用鏈地圖 | ✅ 完成 | - |
| 1.4 | 題目設計：CtsDisplayTestCases (15題) | 🔄 初稿完成，待修正難度定義 | - |
| 1.5 | 題目設計：CtsColorModeTestCases (15題) | ⬜ 未開始 | - |
| 1.6 | 題目設計：CtsThemeDeviceTestCases (15題) | ⬜ 未開始 | - |
| 1.7 | 題目設計：CtsBootDisplayModeTestCases (15題) | ⬜ 未開始 | - |
| 1.8 | 實作第一題：埋 bug → build → flash → CTS fail 驗證 | 🔄 開始實作 | - |
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

### 11:50 Baseline 測試
- 在乾淨 AOSP image 上跑 `CtsDisplayTestCases -t testRestrictedFramebufferSize`
- **結果：PASS** ✅ (2 modules, 2 pass, 0 fail, ~100s)
- 確認測試在未修改環境下正常通過

### 12:02 Q005 (Hard) 第一次嘗試 — 系統屬性 bug
- **目標測試：** `testRestrictedFramebufferSize`
- **Bug 方式：** 在 `device-panther.mk` 加入 `ro.surface_flinger.max_graphics_width=0`
- sandbox-1 開始 build
- 同時在 sandbox-2 準備 Q001 (Easy) — HDR 亮度值交換
  - 修改 `Display.java` 第 1263 行：交換 `mMinLuminance` 和 `mMaxAverageLuminance` 參數順序
  - patch 已存

### 12:13 資源衝突
- 兩個 sandbox 同時 build 導致 CPU 過載（load average 73.56 / 16 cores）
- 決定：殺掉 sandbox-2 build，讓 sandbox-1 先完成

### 12:18 sandbox-1 Build 完成 (16分鐘)
- 配置 ccache（50G cache size）寫入 .bashrc
- 開始 flash Pixel 7

### 12:20 ~ 12:50 ⚠️ Flash 失敗 — USB 通訊問題 (Lesson Learned!)
**問題：** `fastboot devices` 可以列出裝置，但所有 `fastboot` 操作指令（getvar/flash）都 hang 住

**根因：** 殘留的 CTS tradefed OLC server 進程（PID 2397182, 2397255）佔用了 USB/fastboot 控制權。
這些進程是從前一次 CTS baseline 測試啟動的，即使測試結束也不會自動退出。

**排查過程：**
1. 最初以為是 bootloader locked → 確認是 unlocked ✅
2. 換 USB 口 → 新口完全看不到裝置（那個口沒 data 功能）
3. 殺掉 CTS 殘留進程 → 仍然 hang
4. 拔插 USB + 強制重啟手機到 fastboot → 仍然 hang
5. 手機嘗試開機 → bootloop（Google logo 卡住）
6. 最終解決：**插回原 USB 口 + 長按電源 30 秒強制關機 + 重新進 fastboot** → fastboot 通訊恢復！

**🔴 Lesson Learned:**
1. **跑完 CTS 後必須殺掉 tradefed/OLC server 殘留進程**，否則它們會佔用 USB 讓 fastboot 無法操作
   ```bash
   # CTS 測試後清理
   pkill -f "ats_console_deploy\|olc_server" 
   ```
2. **`fastboot devices` 能列出 ≠ fastboot 能通訊**。USB enumeration 成功不代表 protocol 通訊正常
3. **換 USB 口前先確認那個口有 data 功能**
4. **bootloop 不等於磚**：如果 flash 從未成功完成，手機上還是原本的 image，只是 USB 狀態異常導致開不了機
5. **強制關機要按夠久**（30秒），快速按只是 soft reboot

### 12:50 ~ 13:03 修復手機 + Flash 成功
- 插回原 USB 口，強制關機重進 fastboot
- `fastboot getvar unlocked` 秒回 → 通訊恢復！
- `fastboot -w flashall` 成功，71 秒完成
- 手機正常開機

### 13:04 Q005 Property 注入
- **發現：** `PRODUCT_DEFAULT_PROPERTY_OVERRIDES` 在 device-panther.mk 中的設定沒有出現在 `getprop` 裡
  - build.prop 裡有 `ro.surface_flinger.max_graphics_width=1920`（build output 確認）
  - 但裝置上 getprop 完全看不到
  - 原因待查（可能是 property 載入順序或 build system 問題）
- **Workaround：** 用 `adb remount` + 直接寫入 `/vendor/build.prop`
  ```
  ro.surface_flinger.max_graphics_width=0
  ro.surface_flinger.max_graphics_height=0
  ```
- Reboot 後 `getprop` 確認值為 `0` ✅

### 13:13 Q005 CTS 測試結果
- **結果：2 FAIL / 0 PASS** ✅
- **Fail message:** `expected:<[]> but was:<[0]>`
- **位置：** `DisplayTest.java:1086`
- **兩個 variant 都 fail：** regular + instant

### 13:14 Q005 驗證評估
| 驗證項目 | 結果 | 說明 |
|---|---|---|
| Bug 存在 | ✅ | property=0 已生效 |
| CTS FAIL | ✅ | 2/2 modules fail |
| Fail 原因符合預期 | ⚠️ | 字串比對 `""` vs `"0"`，不是數值邏輯錯誤 |
| 診斷價值 | ⚠️ | `expected:<[]> but was:<[0]>` 太直白，一看就知道是 property 問題 |
| 難度匹配 | ❌ | Hard 題需要跨 3+ 檔案追蹤，但這題只需看一個 property |

**結論：** Q005 作為 hard 題不合格。Bug 方式太簡單（改 property），fail message 太洩題。
需要重新設計，用跨多檔案的調用鏈 bug。

**但流程已驗通：** build → flash → property 注入 → CTS fail → 結果收集 ✅

---

## ⚠️ 重要 Lessons Learned

### 1. CTS 殘留進程會搶佔 USB
跑完 CTS 後，tradefed 的 OLC server 不會自動退出，會持續佔用 fastboot/adb。
**每次 CTS 測試後必須清理：**
```bash
pkill -f "ats_console_deploy\|olc_server"
```

### 2. PRODUCT_DEFAULT_PROPERTY_OVERRIDES 可能不生效
在 device-panther.mk 用 `PRODUCT_DEFAULT_PROPERTY_OVERRIDES` 加的 property 不一定出現在 getprop 裡。
**Workaround：** `adb remount` 後直接寫 `/vendor/build.prop`
**TODO：** 搞清楚正確的 property 注入方式（可能需要用 `PRODUCT_VENDOR_PROPERTIES`）

### 3. 驗證清單（每題必做）
1. Bug 確實存在（property/代碼修改生效）
2. CTS 測試確實 FAIL（不是 pass/error/skip）
3. Fail 原因符合預期（是因為埋的 bug，不是別的原因）
4. Fail message 有診斷價值（學員能從 log 追溯到 root cause）
5. 只有目標測試 fail（沒有連帶搞壞其他東西）
6. 難度匹配（fail message 不能太洩題，也不能完全沒線索）

### 待辦
- [ ] 調查 `PRODUCT_DEFAULT_PROPERTY_OVERRIDES` vs `PRODUCT_VENDOR_PROPERTIES` 差異
- [ ] 完成 Q001 (Easy) 驗證（sandbox-2 正在 build）
- [ ] 重新設計 Q005 (Hard)，改用跨 3 檔案調用鏈
- [ ] 建立自動化 CTS 測試腳本（含 CTS 殘留進程清理）
- [ ] 繼續 easy/medium 題目實作
