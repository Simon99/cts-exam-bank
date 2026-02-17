# Issue 修復流程

**版本**：1.0
**更新日期**：2026-02-11

---

## 概述

當 CTS 題目驗證失敗（bug patch 無法被測試偵測、系統崩潰等），需要進行 Issue 修復。本文件記錄完整的修復流程。

---

## 目錄結構

```
cts-exam-bank/
├── 需要fix的問題/           # 待處理 + 已解決的 Issue
│   ├── Issue_XXXX_*.md              # 待處理
│   └── [Resolved]_Issue_XXXX_*.md   # 已解決（加 prefix）
├── issues_resolved/          # 解決記錄（含完整分析）
│   └── Issue_XXXX_*_RESOLVED.md
└── domains/<domain>/<difficulty>/   # 題庫檔案
    ├── QXXX_bug.patch
    ├── QXXX_question.md
    ├── QXXX_answer.md
    └── QXXX_meta.json
```

---

## 修復流程

### Phase 1：問題分析

1. **讀取 Issue 檔案**
   ```
   需要fix的問題/Issue_XXXX_<ID>_<description>.md
   ```

2. **確認問題類型**
   - Bug patch 無法被 CTS 偵測（測試 PASS）
   - Bug 導致系統崩潰
   - Patch 無法套用（路徑/行號錯誤）
   - 其他

3. **定位題目檔案**
   ```
   domains/<domain>/<difficulty>/QXXX_bug.patch
   domains/<domain>/<difficulty>/QXXX_question.md
   domains/<domain>/<difficulty>/QXXX_answer.md
   ```

### Phase 2：修復 Bug Patch

1. **分析 CTS 測試行為**
   - 測試實際驗證什麼？
   - 測試傳入什麼參數？
   - 什麼條件會導致 FAIL？

2. **設計新的 Bug**
   - Bug 必須能被現有 CTS 測試偵測
   - Bug 不能導致系統崩潰
   - Bug 應該有教學價值

3. **更新 `QXXX_bug.patch`**
   - 包含完整 header（檔案路徑、CTS 測試名、預期結果）
   - 使用標準 unified diff 格式

### Phase 3：驗證修復

1. **Dry-run 測試**
   ```bash
   cd ~/develop_claw/aosp-sandbox-1
   git apply --check <patch_file>
   ```

2. **套用 Patch**
   ```bash
   git apply <patch_file>
   ```

3. **重建受影響模組**
   ```bash
   source build/envsetup.sh
   lunch aosp_panther-trunk_staging-userdebug
   m <module>  # 例如：m services
   ```

4. **推送到設備**
   ```bash
   adb root
   adb remount
   adb push out/target/product/panther/system/framework/services.jar /system/framework/
   adb reboot
   ```

5. **執行 CTS 測試**
   ```bash
   atest <test_class>#<test_method>
   ```

6. **確認結果**
   - 預期結果通常是 FAIL（測試偵測到 bug）
   - 記錄實際錯誤訊息

### Phase 4：更新題庫

1. **更新 `QXXX_question.md`**
   - 修正測試失敗訊息
   - 調整提示（符合新 bug 邏輯）
   - 確保任務描述清晰

2. **更新 `QXXX_answer.md`**
   - 描述正確的 bug 位置
   - 解釋 bug 成因
   - 提供修復方案
   - 更新關鍵教訓

3. **確認一致性**
   | 檔案 | 應該一致的內容 |
   |------|---------------|
   | bug.patch | Bug 的實際程式碼 |
   | question.md | 測試失敗訊息、提示 |
   | answer.md | Bug 分析、修復方案 |

### Phase 5：記錄解決

1. **建立解決記錄**
   ```
   issues_resolved/Issue_XXXX_<ID>_RESOLVED.md
   ```
   
   內容包含：
   - 問題根因
   - 修復方式
   - 驗證結果

2. **標記原 Issue 為已解決**
   ```bash
   mv "Issue_XXXX_*.md" "[Resolved]_Issue_XXXX_*.md"
   ```

---

## 解決記錄模板

```markdown
# Issue XXXX: <ID> — 已解決

## 基本資訊
- **題目 ID**: <ID> (<domain>/<difficulty>/QXXX)
- **原始問題**: <簡述>
- **解決日期**: YYYY-MM-DD

---

## 1. 問題根因

<詳細說明為什麼原本的設計有問題>

---

## 2. 修復方式

**方案**：<簡述修復策略>

```diff
<修復的 diff>
```

**修復流程**：
1. <步驟>
2. <步驟>
...

---

## 3. 驗證結果

✅ **測試通過驗證**

- **測試名稱**: <完整測試名>
- **預期結果**: <PASS/FAIL>
- **實際結果**: <PASS/FAIL>
- **錯誤訊息**（如適用）: <訊息>

---

## 相關檔案
- Bug Patch: `domains/<domain>/<difficulty>/QXXX_bug.patch`
- 題目: `domains/<domain>/<difficulty>/QXXX_question.md`
- 答案: `domains/<domain>/<difficulty>/QXXX_answer.md`
```

---

## 常見問題

### Q: Patch 套用失敗怎麼辦？
A: 檢查路徑和行號，可能需要手動調整 context lines 或使用 `--3way` 選項。

### Q: 重建哪個模組？
A: 根據修改的檔案決定：
- `DisplayManagerService.java` → `m services`
- `SurfaceFlinger` 相關 → `m surfaceflinger`
- Framework 資源 → `m framework-res`

### Q: 測試結果不如預期？
A: 
1. 確認 patch 確實被套用（檢查原始碼）
2. 確認正確的 jar/so 被推送
3. 確認設備重啟完成
4. 檢查測試是否針對正確的行為

---

## 版本歷史

| 版本 | 日期 | 變更 |
|------|------|------|
| 1.0 | 2026-02-11 | 初版，基於 DIS-H001 修復經驗 |
