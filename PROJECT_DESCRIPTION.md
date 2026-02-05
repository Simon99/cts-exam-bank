# CTS/GTS 面試題庫專案 — 完整描述

## 一、專案目標

為 Android 系統工程師面試建立一套 **上機實作考題庫**。候選人拿到一台「有 bug 的手機」和對應的 AOSP 原始碼，從 CTS 失敗的 log 出發，追蹤源碼、定位問題、提出修復方案。

**考察核心能力：**
- Log 分析與問題定位
- AOSP 源碼追蹤（跨檔案、跨層級）
- 修復方案的正確性與是否有 side effect
- 系統性思維（不是修了一處就交差）

## 二、考試形式

| 項目 | 說明 |
|------|------|
| 提供物 | 有 bug 的手機/image + CTS fail log + 完整 AOSP 源碼 |
| 候選人可做 | 讀 log、讀源碼、加 log、編譯 debug image、flash 手機 |
| 時間限制 | 無 |
| 評分 | 定位準確性、修復方案品質、是否理解 root cause |

## 三、難度定義

> ⚠️ 難度 ≠ bug 埋的層級深淺。難度 = 追蹤路徑的複雜度。

### Easy（初級）
- **讀 log 就能定位問題**
- Bug 在單一檔案，fail log 直接指向出錯位置
- 候選人只需要讀 log → 找到對應源碼 → 修復

### Medium（中級）
- **需要自己添加額外 log 才能定位**
- Bug 牽連 2 個檔案，fail log 出現在 A，但問題根因在 B
- 候選人需要理解 A 呼叫了 B，在 B 加 log 追蹤才能定位

### Hard（高級）
- **錯誤邏輯橫跨至少 3 個檔案**
- Log 出現在 A 的函數 aa → aa 呼叫 B 的函數 bb → bb 呼叫 C 的函數 cc → 實際 bug 在 cc
- 或者：A 的問題是 B 和 C **同時有 bug** 造成的，必須全部找到並修復

## 四、Bug Pattern 分類

### Pattern A：縱向單點（適用 Easy）
```
[CTS Test] → [File A: 函數 X] ← bug 在這裡
                    ↑
              log 直接指出
```

### Pattern B：橫向呼叫鏈（適用 Medium）
```
[CTS Test] → [File A: 函數 X] → [File B: 函數 Y] ← bug 在這裡
                    ↑
              log 出現在這裡
```

### Pattern C：聯合觸發（適用 Hard）
```
[CTS Test] → [File A: 症狀]
                 ↗        ↖
     [File B: bug 1]   [File C: bug 2]
     必須同時修復 B 和 C，測試才能通過
```

### Pattern D：資料流扇出（適用 Hard）
```
        [Data Source]
        ↙    ↓    ↘
    [Consumer B] [Consumer C] [Consumer D]
      bug 1        bug 2
    兩個消費者各自的轉換邏輯出錯
```

## 五、題庫規模

### 終極目標
五大領域 × 多模組 × 3 難度 × 5 題 = **405 題（初期）**，未來成長到數千題。

| 領域 | 模組數 | 題數 |
|------|--------|------|
| Framework 核心 | 8 | 120 |
| 圖形 | 5 | 75 |
| 顯示 | 4 | 60 |
| 多媒體 | 7 | 105 |
| 相機 | 3 | 45 |
| **合計** | **27** | **405** |

### 目前進行中的模組

| 模組 | CTS Module | 題數 | 狀態 |
|------|-----------|------|------|
| 多媒體 | MctsMediaV2TestCases | 6 (2E/2M/2H) | patch 有，1/6 驗證通過 |
| 相機 | CtsCameraTestCases | 18 (6E/6M/6H) | patch 有，未驗證 |
| 視窗管理 | CtsWindowManagerJetpackTestCases | 9 (3E/3M/3H) | patch 有，未驗證 |
| 遊戲幀率 | CtsGameFrameRateTestCases | 9 (3E/3M/3H) | patch 有，未驗證 |
| 金鑰儲存 | CtsKeystoreTestCases | 9 (3E/3M/3H) | patch 有，未驗證 |
| 顯示 | CtsDisplayTestCases | 15 (5E/5M/5H) | 4E 驗證通過，patch 未收集 |
| 顯示-色彩 | CtsColorModeTestCases | 待規劃 | — |
| 顯示-主題 | CtsThemeDeviceTestCases | 待規劃 | — |
| 顯示-開機模式 | CtsBootDisplayModeTestCases | 待規劃 | — |

**當前總計：66 題（有 patch 或已驗證）**

## 六、環境

| 資源 | 路徑/說明 |
|------|----------|
| AOSP 乾淨源碼 | `~/aosp-panther/` (Pixel 7 / Panther, Android 14) — **不動** |
| 沙盒 1 | `~/develop_claw/aosp-sandbox-1/` |
| 沙盒 2 | `~/develop_claw/aosp-sandbox-2/` |
| Private Repo | `~/develop_claw/cts-exam-bank/` → `github.com/Simon99/cts-exam-bank.git` |
| CTS 工具 | `~/cts/14_r7-linux_x86-arm/android-cts/` |
| ADB | `~/aosp-panther/out/host/linux-x86/bin/adb` |
| 測試裝置 A | Pixel 7 (2B231FDH200B4Z) — USB 異常待修復 |
| 測試裝置 B | Pixel 7 (27161FDH20031X) — 在線 ✅ |
| 題庫管理（repo） | `~/develop_claw/cts-exam-bank/` → GitHub private repo |
| 磁碟空間 | /home 1.7T，可用 ~860G |

## 七、每題交付物

```
cts-exam-bank/domains/<domain>/<CtsModuleName>/<difficulty>/
├── DESIGN.md                    # 該難度所有題目的設計方案
├── Q001_bug.patch               # 引入 bug 的 patch
├── Q001_question.md             # 題目描述（給候選人看的）
├── Q001_answer.md               # 完整解答（評分用）
├── Q001_meta.json               # 後設資料（含 cts_fail_items）
├── Q001_results/
│   └── test_result.xml          # CTS 失敗的結果 XML
└── ...

> fix.patch 不預先製作，從面試者收集。revert bug patch ≠ 有效的修復方案。
```

**Repo 結構：**
```
cts-exam-bank/
├── domains/
│   ├── display/                 # 顯示領域
│   │   ├── CtsDisplayTestCases/
│   │   ├── CtsColorModeTestCases/
│   │   ├── CtsThemeDeviceTestCases/
│   │   └── CtsBootDisplayModeTestCases/
│   ├── multimedia/              # 多媒體領域
│   │   └── MctsMediaV2TestCases/
│   ├── framework/               # Framework 核心領域
│   │   ├── CtsWindowManagerJetpackTestCases/
│   │   └── CtsKeystoreTestCases/
│   ├── graphics/                # 圖形領域
│   │   └── CtsGameFrameRateTestCases/
│   └── camera/                  # 相機領域
│       └── CtsCameraTestCases/
├── lessons_learned/             # 經驗教訓（按類別）
│   ├── boot_safety.md           # 哪些修改會導致無法開機
│   ├── build_deploy.md          # 編譯和刷機注意事項
│   ├── usb_issues.md            # USB/fastboot 連線問題
│   ├── cts_testing.md           # CTS 測試設計注意事項
│   └── issue_list.md            # 問題現象索引（方便追蹤）
├── PROJECT_DESCRIPTION.md
├── PROJECT_DESCRIPTION.html
└── WORKLOG.md
```

## 八、品質要求（每題必過的驗證清單）

- [ ] bug.patch 能在乾淨 AOSP 上成功 apply
- [ ] Full build 成功（`make -j$(nproc)`，不用增量編譯）
- [ ] Flash 後正常開機（不 bootloop）
- [ ] 目標 CTS 測試 FAIL（而非 SKIP/ASSUMPTION_FAILURE）
- [ ] Fail 原因符合預期設計
- [ ] 有診斷價值（候選人能從 log 出發追蹤）
- [ ] 只影響目標測試（不引起大面積 CTS 崩潰）
- [ ] 難度匹配（Easy=1 檔案 / Medium=2 檔案 / Hard=3+ 檔案）
- [ ] answer.md 包含追蹤路徑和評分標準

## 九、已知限制與教訓

### 技術限制
| 問題 | 說明 | 應對 |
|------|------|------|
| AOSP 缺權限 | `BRIGHTNESS_SLIDER_USAGE` 不存在 → brightness tracking 測試 SKIP | 避開相關測試 |
| LogicalDisplay 核心邏輯 | 修改 `updateLocked()` = bootloop（已 full build 實測確認） | bug 落點只放在 API 層和 client side |
| 增量編譯不可靠 | `m services` + `make systemimage` 可能產出不一致 image | 一律 full build |
| fastboot USB 狀態 | `fastboot devices` 能列出 ≠ 能通訊 | 異常時需手動拔插 USB + 長按電源 30 秒 |
| CTS 殘留進程 | tradefed OLC server 佔用 USB | `pkill -f "ats_console_deploy\|olc_server"` |
| property override | `PRODUCT_DEFAULT_PROPERTY_OVERRIDES` 可能不生效 | workaround: remount + 直接寫 build.prop |

### 設計限制
| 問題 | 說明 |
|------|------|
| Assume vs Assert | 目標測試必須用 `Assert`（會 FAIL），用 `Assume` 的會被 SKIP |
| APEX 組件 | 軟體 codec 在 APEX 中，不能用 adb push 熱更新，需完整 build |
| 單題獨立性 | 每題的 bug 必須互不干擾，不能多題 patch 同時 apply |

## 十、Bug Pattern 安全區域（Display 模組實測結果）

### 🔴 禁區（會 bootloop）
- `LogicalDisplay.updateLocked()` 核心邏輯（mInfo cache、supportedModes 截斷）
- `LocalDisplayAdapter` 初始化路徑
- `DisplayManagerService.performTraversalLocked()` / `configureDisplayLocked()`
- SurfaceFlinger / native 層

### 🟢 安全區（已驗證不影響開機）
- `Display.java` 客戶端 API
- `DisplayManagerService` 的 Binder API 層（public 方法）
- `DisplayInfo.java` Parcel 序列化
- `ColorDisplayService` / `DisplayTransformManager` 色彩管理鏈
- `DisplayManagerGlobal.java` 客戶端快取
- system property 修改
