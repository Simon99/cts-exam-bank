# CTS Testing — 測試設計注意事項

## 使用 USE_ATS=false 執行 CTS（推薦）

### 背景
CTS 14 預設使用 OLC (OmniLab Client) Server 架構，但 OLC 的裝置偵測有時會失敗（`Device count: 0`）。

### 解法
設定 `USE_ATS=false` 使用舊版 tradefed 直接執行：

```bash
export USE_ATS=false
cd ~/cts/14_r7-linux_x86-arm/android-cts
./tools/cts-tradefed run cts -m CtsDisplayTestCases -s <device_serial>
```

### Tradefed vs OLC 比較

| 項目 | Tradefed (USE_ATS=false) | OLC (USE_ATS=true) |
|------|--------------------------|---------------------|
| 裝置偵測 | DeviceManager 直接用 adb | OLC server 獨立偵測 |
| 穩定性 | ✅ 成熟穩定 | ⚠️ 有時偵測不到裝置 |
| 適用場景 | 本地測試 | Lab 環境 |

---

## 雙裝置 CTS 不能同時跑（OLC Server 碰撞）

### 現象
兩台手機分別在兩個 console 啟動 CTS 時，OLC server 只有一個實例。
- 第二個 console 啟動 CTS → OLC server 不回應（被第一個佔著）
- 如果 pkill OLC server 讓第二個能跑 → 第一個 CTS 斷掉
- 第一個 retry → 又搶走 OLC server → 第二個斷掉
- 無限循環，兩邊都跑不完

### 規則
**同一時間只能有一個 CTS 測試在執行。兩台手機必須輪流測試，不能並行。**

### 工作流程
1. 裝置 A 跑 CTS → 等完成
2. 清理 OLC server：`pkill -f "ats_console_deploy\|olc_server"`
3. 裝置 B 跑 CTS → 等完成
4. 清理

---

## Assert vs Assume

### 規則
目標測試的驗證邏輯必須使用 `Assert`，不能用 `Assume`。

| 方法 | 條件不滿足時 | 能當考題嗎 |
|------|-------------|-----------|
| `Assert.assertTrue()` | 測試 **FAIL** | ✅ 可以 |
| `Assume.assumeTrue()` | 測試 **SKIP** | ❌ 不行 |

### 踩坑案例
- AOSP 缺 `BRIGHTNESS_SLIDER_USAGE` 權限 → brightness tracking 相關測試全部 `ASSUMPTION_FAILURE`（SKIP）
- 這類測試不能用來出題

## APEX 組件限制

### 現象
- 軟體 codec（如 C2SoftAvcDec）在 APEX 中
- `adb push` 到 `/system/lib64/` 無效，不會被載入

### 規則
- APEX 內的組件修改 → 必須完整 build + flash
- Framework 層 Java 修改 → 也建議 full build（安全起見）

## 單題獨立性

### 規則
- 每題的 bug 必須互不干擾
- 不能出現「A 題的 patch 影響了 B 題的測試結果」
- 驗證時必須在乾淨 AOSP 上只 apply 單題 patch

### 踩坑案例
- MctsMediaV2 驗證時多個 patch 同時 apply → 互相干擾
- Easy patch 導致 data extraction 失敗 → Medium/Hard 的 decoder 測試也連帶報錯
- 結果：6 題只有 1 題能確認是自身 patch 導致的 fail

## 驗證清單（每題必過）

1. ☐ bug.patch 在乾淨 AOSP 上 apply 成功
2. ☐ Full build 成功
3. ☐ Flash 後正常開機
4. ☐ 目標 CTS 測試 FAIL（非 SKIP / ASSUMPTION_FAILURE）
5. ☐ Fail 原因符合預期（是埋的 bug 造成的，不是別的原因）
6. ☐ 有診斷價值（log 有足夠線索讓候選人追蹤）
7. ☐ 只影響目標測試（不大面積崩潰）
8. ☐ 難度匹配（Easy=1 檔 / Medium=2 檔 / Hard=3+ 檔）

---

## I-010: CTS 測試的設備限制（TV-Only 等）

### 問題描述
選用 `DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents` 作為題目的 CTS 測試，但在 Pixel 7 上運行時被跳過（ASSUMPTION_FAILED）。

### 根本原因
`DefaultDisplayModeTest` 類別的 `setUp()` 方法包含：
```java
@Before
public void setUp() throws Exception {
    assumeTrue("Need an Android TV device to run this test.", FeatureUtil.isTV());
    // ...
}
```
這導致整個測試類只能在 Android TV 設備上運行。

### 解決方案
1. **選測試前先檢查設備限制**：
   - 搜索 `assumeTrue`、`FeatureUtil.isTV()`、`FEATURE_LEANBACK` 等關鍵字
   - 確認測試是否有設備類型限制
   
2. **如果測試有限制**：
   - 換一個沒有設備限制的測試
   - 或重新設計 bug，使用其他測試驗證

### 實際處理
原題目 Q010 從 `DefaultDisplayModeTest` 換到 `DisplayTest#testSetUserDisabledHdrTypesStoresDisabledFormatsInSettings`，這個測試在手機上也能運行。

### 教訓
- **CTS 測試有隱藏的設備限制**：不是所有測試都能在所有設備上運行
- **選測試前要驗證可執行性**：先在目標設備上跑一次確認能執行
- **常見的設備限制**：
  - `FeatureUtil.isTV()` — 需要 Android TV
  - `FeatureUtil.isAutomotive()` — 需要 Android Automotive
  - `FeatureUtil.isWatch()` — 需要 Wear OS
  - `PackageManager.FEATURE_*` 檢查 — 各種硬體功能
