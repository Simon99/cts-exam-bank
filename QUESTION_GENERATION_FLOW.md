# CTS 題目生成流程

**版本**: v1.4.0  
**建立日期**: 2026-02-10  
**更新時間**: 2026-02-10 16:57 GMT+8

---

## 核心原則

**從源碼出發，不從題目出發。**

舊流程失敗的原因：先想題目概念 → 猜 API → 產出 patch → API 不存在（LLM 幻覺）

新流程：先分析真實源碼 → 找可注入點 → 設計 bug → 題目配合 patch

---

## 流程步驟

### Phase A：建立注入點分布列表（一次性 / 定期更新）

#### Step A1：CTS 測試分析

**目標**：了解該領域 CTS 測試重點

**輸入**：`cts/tests/<領域>/` 目錄

**輸出**：
- 測試類別清單
- 各測試驗證的功能點
- 重點 API / 方法

---

#### Step A2：AOSP 源碼掃描

**目標**：找出對應 CTS 測試的實作程式碼

**輸入**：
- AOSP 源碼目錄：`~/develop_claw/aosp-sandbox-1/`
- 領域對應的源碼路徑（見下方映射表）

**輸出**：
- 檔案清單 + 重要函數列表
- 程式碼結構概覽

---

#### Step A3：產生注入點分布列表

**目標**：交叉比對 CTS + AOSP，產生完整的注入點清單

**輸出**：`injection-points/<領域>.md`（格式見下方）

**評估標準**：
- [ ] 程式碼區塊足夠獨立（改動不會影響太多地方）
- [ ] bug 效果可預測（能描述會造成什麼問題）
- [ ] 標註建議難度

---

### Phase B：從列表產生題目（每次出題）

#### Step B1：挑選注入點

**目標**：從注入點分布列表中選擇要出題的點

**考量**：
- 難度分布（Easy/Medium/Hard 平衡）
- 避免重複（同一函數不要出太多題）
- CTS 涵蓋度（盡量覆蓋不同測試）

---

#### Step B2：設計 Bug

**目標**：設計具體的 bug 注入方式

**Bug 設計原則**：
1. **真實性** — 這是開發者可能犯的錯誤
2. **可檢測性** — 考生能透過閱讀程式碼發現
3. **影響明確** — 能清楚描述 bug 會造成什麼問題

**難度調整方式**：
| 難度 | 涉及檔案數 | Bug 複雜度 | 程式碼呈現 |
|------|-----------|-----------|-----------|
| Easy | 1 檔案 | 單一明顯錯誤 | 直接顯示 bug 區塊 |
| Medium | 2 檔案 | 跨函數邏輯 | 需要追蹤呼叫鏈 |
| Hard | ≥3 檔案 | 跨模組架構 | 需理解系統設計 |

---

#### Step B3：產生 Patch

**目標**：產生可 apply 的 unified diff patch

**Patch 格式要求**：
```diff
--- a/path/to/file.java
+++ b/path/to/file.java
@@ -起始行,行數 +起始行,行數 @@
 上下文行（至少3行）
-原始程式碼
+注入bug後的程式碼
 上下文行（至少3行）
```

**關鍵檢查點**：
- [ ] 路徑相對於 AOSP 根目錄
- [ ] 行號對應實際源碼（不是猜的）
- [ ] 上下文完全匹配（複製貼上，不要手打）
- [ ] 沒有使用 `xxx` 等佔位符

---

#### Step B4：驗證 Patch

**目標**：確認 patch 能成功套用

**驗證命令**：
```bash
cd ~/develop_claw/aosp-sandbox-1
patch --dry-run -p1 < /path/to/question.patch
```

**結果判定**：
- `patching file ...` + 無錯誤 → ✅ 通過
- `Hunk #N FAILED` → ❌ 行號或上下文錯誤
- `can't find file` → ❌ 路徑錯誤

---

#### Step B5：撰寫題目

**目標**：根據實際 patch 撰寫題目描述

**題目結構**：
```yaml
question: |
  [情境描述]
  [問題陳述]
  [要求考生做什麼]

options:
  A: [選項 - 必須有一個正確答案]
  B: [選項]
  C: [選項]
  D: [選項]

answer: |
  正確答案：[X]
  
  [解釋為什麼是這個答案]
  [說明 bug 的影響]
  [修復方式]
```

**撰寫原則**：
- 題目描述的 bug 必須與 patch 一致
- 不要提及不存在的 API 或方法
- 選項要有鑑別度（不要太明顯或太模糊）

---

### Phase C：實機驗證（題目完成後）

題目必須經過真實設備 + CTS 測試驗證，確保 bug 能實際觸發 CTS fail。

#### Step C1：編譯 Image

**目標**：將注入 bug 的源碼編譯成可刷機的 image

**流程**：
```bash
# 1. 套用 patch 到源碼
cd ~/develop_claw/aosp-sandbox-1
patch -p1 < /path/to/question.patch

# 2. 編譯（以 Pixel 7 panther 為例）
source build/envsetup.sh
lunch aosp_panther-userdebug
m -j$(nproc)

# 3. 產出位置
# out/target/product/panther/
```

**注意**：
- 每次只套用一個 patch 進行驗證
- 編譯前確認源碼乾淨（無其他修改）

---

#### Step C2：刷機

**目標**：將編譯好的 image 刷入測試設備

**流程**：
```bash
# 1. 進入 bootloader
adb reboot bootloader

# 2. 刷入 image
cd out/target/product/panther
fastboot flashall -w

# 3. 等待設備開機完成
adb wait-for-device
```

**設備**：
- 27161FDH20031X (Pixel 7)
- 2B231FDH200B4Z (Pixel 7)

---

#### Step C3：執行 CTS 測試

**目標**：確認 bug 能觸發對應的 CTS fail

**流程**：
```bash
# 1. 啟動 CTS
cd ~/cts-android-14
./android-cts/tools/cts-tradefed

# 2. 執行特定模組測試
run cts -m <模組名稱>

# 範例：測試 display 相關
run cts -m CtsDisplayTestCases
```

**預期結果**：
- 對應的測試項目應該 FAIL
- 如果 PASS → bug 設計有問題，需要回 Phase B 調整

---

#### Step C4：收集 Fail Log

**目標**：提取 CTS fail log 作為題目包的一部分

**Log 位置**：
```
~/cts-android-14/android-cts/results/<timestamp>/
├── test_result.xml          # 測試結果摘要
├── invocation_summary.txt   # 執行摘要
└── logs/                    # 詳細 log
    └── <module>/
        └── <test>/
            └── logcat.txt   # 設備 log
```

**提取內容**：
1. **Fail item 名稱** — 完整的測試方法名
2. **錯誤訊息** — assertion failure 或 exception
3. **相關 logcat** — 設備端錯誤訊息
4. **Stack trace** — 如果有的話

**存放位置**：
```
domains/<領域>/<難度>/Q<編號>/
├── meta.json
├── question.md
├── patch.diff
├── answer.md
└── cts-fail/                 # 新增
    ├── fail_summary.txt      # fail item + 錯誤摘要
    ├── test_result.xml       # 原始測試結果
    └── logcat.txt            # 相關 log 片段
```

---

#### Step C5：還原源碼

**目標**：驗證完成後還原乾淨源碼

**流程**：
```bash
cd ~/develop_claw/aosp-sandbox-1
patch -R -p1 < /path/to/question.patch

# 或使用乾淨 image 刷回
~/aosp-images/flash-clean.sh <serial>
```

---

### 完整流程總覽

```
Phase A：建立注入點分布列表
├── A1：CTS 測試分析
├── A2：AOSP 源碼掃描
└── A3：產生注入點分布列表
         ↓
Phase B：產生題目
├── B1：挑選注入點
├── B2：設計 Bug
├── B3：產生 Patch
├── B4：驗證 Patch (dry-run)
└── B5：撰寫題目
         ↓
Phase C：實機驗證
├── C1：編譯 Image
├── C2：刷機
├── C3：執行 CTS 測試
├── C4：收集 Fail Log
└── C5：還原源碼
         ↓
      ✅ 題目完成
```

---

## CTS 模組結構

注入點分類**直接對應 CTS 模組結構**，確保完整覆蓋所有測試領域。

### CTS 測試模組統計

| 類別 | 路徑 | 模組數 |
|------|------|--------|
| Device-side Tests | `cts/tests/` | 84 |
| Host-side Tests | `cts/hostsidetests/` | 90 |
| **總計** | | **174+** |

### cts/tests/ 模組列表（84 個）

```
acceleration, accessibility, accessibilityservice, admin, AlarmManager,
ambientcontext, app, appcloning, appintegrity, apppredictionservice,
appsearch, aslr, attentionservice, attestationverification, atv,
autofillservice, backup, BlobStore, bugreport, camera, cloudsearch,
contentcaptureservice, contentsuggestions, controls, core, credentials,
devicepolicy, devicestate, DropBoxManager, expectations, filesystem,
fragment, framework, input, inputmethod, jdwp, JobScheduler,
JobSchedulerSharedUid, leanbackjank, libcore, location, media, mediapc,
MediaProviderTranscode, mocking, musicrecognition, net, netlegacy22.api,
netlegacy22.permission, netsecpolicy, ondevicepersonalization, openglperf2,
pdf, perfetto, PhotoPicker, process, providerui, quickaccesswallet,
quicksettings, rollback, rotationresolverservice, sample, searchui,
security, sensitivecontentprotection, sensor, ServiceKillTest, signature,
simplecpu, smartspace, storageaccess, surfacecontrol, suspendapps, tare,
tests, translation, trust, tvprovider, vibrator, video, videocodec, vr,
wallpapereffectsgeneration, wearable
```

### cts/hostsidetests/ 模組列表（90 個）

```
accounts, adb, adbmanager, adpf, angle, apex, appbinding, appcloning,
appcompat, appsearch, appsecurity, art, atrace, backup, biometrics,
blobstore, bootstats, calllog, car, car_builtin, classloaders, classpath,
compilation, content, cpptools, credentials, ctsverifier, deviceidle,
devicepolicy, dexmetadata, dumpsys, edi, gputools, grammaticalinflection,
graphics, gwp_asan, harmfulappwarning, hdmicec, incident, incrementalinstall,
inputmethodservice, install, jvmti, media, mediaparser, multidevices,
multiuser, net, os, packagemanager, permissions, phonenumbers, print,
profiling, rollback, sandbox, scopedstorage, seccomp, securitybulletin,
settings, shortcuts, silentupdate, stagedinstall, statsd, storaged,
systemui, tagging, telecom, telephony, testharness, theme, time,
translation, tv, ui, usb, userspace_reboot, vibrator, webkit, wificond,
wm, ...
```

### 掃描策略

1. **先看 CTS 測試** — 了解該模組在測什麼、重點 API 有哪些
2. **再看 AOSP 實作** — 找對應的實作程式碼
3. **交叉比對** — CTS 測的功能 ↔ AOSP 實作位置 → 產生「注入點分布列表」

---

## 注入點分布列表

掃描的最終產出是一份**注入點分布列表**，不是直接產生題目。

### 目錄結構

注入點列表**直接對應 CTS 模組結構**：

```
injection-points/
├── tests/                          # 對應 cts/tests/
│   ├── app.md
│   ├── camera.md
│   ├── media.md
│   ├── net.md
│   ├── location.md
│   ├── JobScheduler.md
│   ├── ... (84 個模組)
│   └── wearable.md
├── hostsidetests/                  # 對應 cts/hostsidetests/
│   ├── appsecurity.md
│   ├── graphics.md
│   ├── media.md
│   ├── net.md
│   ├── ... (90 個模組)
│   └── wm.md
└── _index.md                       # 總索引
```

### 列表格式

每個 CTS 模組一份清單：

```markdown
# <CTS模組名稱> 注入點分布列表

**CTS 路徑**: `cts/tests/<模組>/` 或 `cts/hostsidetests/<模組>/`
**更新時間**: YYYY-MM-DD

## 概覽
- 總注入點數：N
- 按難度分布：Easy(X) / Medium(Y) / Hard(Z)
- 涵蓋測試類別：[列出主要 Test Class]

## 對應 AOSP 源碼路徑
- `frameworks/base/...`
- `frameworks/av/...`
- ...

## 注入點清單

### 1. <功能子模組>

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| CAM-001 | Camera2Client.cpp | takePicture() | 234-280 | COND, ERR | Medium | CaptureTest |
| CAM-002 | ... | ... | ... | ... | ... | ... |

### 2. <另一個功能子模組>
...
```

### 可注入類型標籤

- `COND` — 條件判斷（if/else、switch、比較運算符）
- `BOUND` — 邊界檢查（陣列索引、null 檢查、範圍驗證）
- `RES` — 資源管理（open/close、acquire/release）
- `STATE` — 狀態轉換（狀態機、flag、模式切換）
- `CALC` — 數值計算（運算符、單位轉換、精度）
- `STR` — 字串處理（比較、解析、格式化）
- `SYNC` — 同步問題（鎖、競態條件）
- `ERR` — 錯誤處理（例外、回傳值檢查）

### 使用流程

```
注入點分布列表
      ↓
[人工挑選] 選擇要出題的注入點
      ↓
[設計 Bug] 根據注入點特性，設計具體 bug
      ↓
[調整難度] 透過程式碼複雜度調整難度
      ↓
[產生題目] Patch + Question + Answer
```

---

## 自動化腳本

### 批量驗證 patch
```bash
#!/bin/bash
# verify-patches.sh

AOSP_ROOT=~/develop_claw/aosp-sandbox-1
DOMAINS_DIR=~/develop_claw/cts-exam-bank/domains

for domain in "$DOMAINS_DIR"/*/; do
  for difficulty in "$domain"*/; do
    for q in "$difficulty"Q*/; do
      patch_file="$q/patch.diff"
      if [ -f "$patch_file" ]; then
        result=$(cd "$AOSP_ROOT" && patch --dry-run -p1 < "$patch_file" 2>&1)
        if echo "$result" | grep -q "FAILED\|can't find"; then
          echo "❌ $q"
        else
          echo "✅ $q"
        fi
      fi
    done
  done
done
```

---

## 迭代紀錄

### v1.4.0 (2026-02-10)
- 重構分類結構：直接對應 CTS 模組（174+ 個），不再限制 10 個領域
- 列出完整 cts/tests/（84 個）和 cts/hostsidetests/（90 個）模組
- 更新 injection-points/ 目錄結構對應 CTS 結構

### v1.3.0 (2026-02-10)
- 新增 Phase C：實機驗證（編譯 → 刷機 → CTS 測試 → 收集 log）
- 定義 cts-fail/ 目錄結構，存放 fail log 作為題目包組成
- 完善完整流程總覽圖

### v1.2.0 (2026-02-10)
- 重構流程為兩階段：Phase A（建立列表）+ Phase B（產生題目）
- 新增「注入點分布列表」概念與格式規範
- 新增可注入類型標籤（COND/BOUND/RES/STATE/CALC/STR/SYNC/ERR）
- 強調：掃描產出是「列表」，不是直接產生題目

### v1.1.0 (2026-02-10)
- 新增 CTS 測試源碼路徑映射
- 新增掃描策略：CTS 測試 → AOSP 實作 → 交叉比對

### v1.0.0 (2026-02-10)
- 初版流程建立
- 從 300 題審查經驗中總結出「從源碼出發」原則
- 定義 6 步驟流程

---

## 待改進項目

- [ ] 源碼掃描自動化腳本
- [ ] 注入點資料庫建立
- [ ] 題目生成模板標準化
- [ ] 批量生成 + 驗證 pipeline

---

**文件位置**: `~/develop_claw/cts-exam-bank/QUESTION_GENERATION_FLOW.md`
