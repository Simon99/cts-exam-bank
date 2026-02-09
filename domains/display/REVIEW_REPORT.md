# Display 題庫審查報告

**審查日期**: 2025-02-10
**審查員**: Clawd (subagent: review-display)

## 一、題目數量統計

| 難度 | 題目數量 | 檔案完整性 |
|------|----------|-----------|
| Easy | 10 題 | ✓ 全部完整 |
| Medium | 10 題 | ⚠️ Q007, Q008 缺少 answer.md |
| Hard | 10 題 | ✓ 全部完整 |

---

## 二、嚴重問題 🚨

### 2.1 難度定義違規

**難度定義標準：**
- Easy: 單一檔案，log 直接指向問題
- Medium: 2 個檔案，log 在 A 但 bug 在 B
- Hard: 3+ 個檔案，呼叫鏈或多處 bug

#### Hard 題目（嚴重違規）

| 題目 | 實際涉及檔案數 | 應有難度 | 狀態 |
|------|---------------|---------|------|
| Hard Q001 | 1 | Easy/Medium | ❌ 需重分類 |
| Hard Q002 | 1 | Easy | ❌ 需重分類 |
| Hard Q003 | 1 | Easy/Medium | ❌ 需重分類 |
| Hard Q004 | 1 | Easy/Medium | ❌ 需重分類 |
| Hard Q005 | 3 | Hard | ✓ 正確 |
| Hard Q006 | 1 | Easy/Medium | ❌ 需重分類 |
| Hard Q007 | 3 | Hard | ✓ 正確 |
| Hard Q008 | 2 | Medium | ❌ 需重分類 |
| Hard Q009 | 1 | Easy/Medium | ❌ 需重分類 |
| Hard Q010 | 1 | Easy | ❌ 需重分類 |

**結論：Hard 題目中只有 Q005, Q007 符合難度定義（20%）**

#### Medium 題目（全部違規）

| 題目 | 實際涉及檔案數 | 應有難度 | 狀態 |
|------|---------------|---------|------|
| Medium Q001 | 1 | Easy | ❌ 需重分類 |
| Medium Q002 | 1 | Easy | ❌ 需重分類 |
| Medium Q003 | 1 | Easy | ❌ 需重分類 |
| Medium Q004 | 1 | Easy | ❌ 需重分類 |
| Medium Q005 | 1 | Easy | ❌ 需重分類 |
| Medium Q006 | 1 | Easy | ❌ 需重分類 |
| Medium Q007 | 1 | Easy | ❌ 需重分類 (meta 也錯標為 hard) |
| Medium Q008 | 1 | Easy | ❌ 需重分類 (meta 也錯標為 hard) |
| Medium Q009 | 1 | Easy | ❌ 需重分類 |
| Medium Q010 | 1 | Easy | ❌ 需重分類 (meta 也錯標為 hard) |

**結論：Medium 題目全部違規（0%），都應該是 Easy**

#### Easy 題目

| 題目 | 實際涉及檔案數 | 狀態 |
|------|---------------|------|
| Easy Q001-Q010 | 全部 1 個 | ✓ 全部正確 |

---

### 2.2 Meta.json 難度標記錯誤

| 題目 | 資料夾位置 | meta.json 難度 | 狀態 |
|------|-----------|---------------|------|
| Medium/Q007 | medium/ | hard | ❌ 錯誤 |
| Medium/Q008 | medium/ | hard | ❌ 錯誤 |
| Medium/Q010 | medium/ | hard | ❌ 錯誤 |

---

### 2.3 Patch 格式問題

| 題目 | 問題描述 |
|------|---------|
| Easy Q005 | 路徑 `vendor.prop` 不存在於標準 AOSP |
| Medium Q002 | 使用絕對路徑格式而非標準 git diff |
| Medium Q007 | Patch 路徑有 `frameworks/base/` 前綴 |
| Medium Q008 | Patch 路徑有 `frameworks/base/` 前綴 |

---

### 2.4 缺少檔案

| 題目 | 缺少檔案 |
|------|---------|
| Medium Q007 | answer.md |
| Medium Q008 | answer.md |

---

## 三、路徑驗證結果

### AOSP 路徑存在性（全部通過）

✓ core/java/android/view/Display.java
✓ core/java/android/view/DisplayInfo.java
✓ services/core/java/com/android/server/display/DisplayManagerService.java
✓ services/core/java/com/android/server/display/LocalDisplayAdapter.java
✓ services/core/java/com/android/server/display/LogicalDisplay.java
✓ services/core/java/com/android/server/display/LogicalDisplayMapper.java
✓ services/core/java/com/android/server/display/VirtualDisplayAdapter.java
✓ services/core/java/com/android/server/display/OverlayDisplayAdapter.java
✓ services/core/java/com/android/server/display/PersistentDataStore.java
✓ services/core/java/com/android/server/display/DisplayPowerController.java
✓ services/core/java/com/android/server/display/mode/DisplayModeDirector.java

### 不存在路徑

❌ `vendor.prop` (Easy Q005) - 設備特定配置，不在標準 AOSP
❌ `device/google/panther/vendor.prop` - panther 設備目錄不存在

---

## 四、禁區檢查

**禁區方法（會導致 bootloop）：**
- LogicalDisplay.updateLocked() 核心邏輯
- LocalDisplayAdapter 初始化路徑
- DisplayManagerService.performTraversalLocked()

**檢查結果：✓ 無題目觸及禁區**

---

## 五、建議修正方案

### 5.1 緊急修正（難度重分類）

**目前實際難度分布：**
- 真正的 Easy 題目：30 題（Easy 10 + Medium 10 + Hard 中的 8 題）
- 真正的 Medium 題目：1 題（Hard Q008 涉及 2 個檔案）
- 真正的 Hard 題目：2 題（Hard Q005, Q007 涉及 3 個檔案）

**建議：**
1. 保留 Hard Q005, Q007 在 Hard 資料夾
2. 移動 Hard Q008 到 Medium（2 檔案）
3. 其餘 Hard 題目移動到 Easy 或 Medium
4. 所有 Medium 題目移動到 Easy
5. 創建真正的 Medium/Hard 題目（涉及多檔案追蹤）

### 5.2 補充缺失檔案

- 創建 Medium/Q007_answer.md
- 創建 Medium/Q008_answer.md

### 5.3 修正 Patch 格式

- Easy Q005：改用設備無關的 bug 或明確說明設備依賴
- Medium Q002：改用標準 git diff 格式
- Medium Q007, Q008：移除 `frameworks/base/` 路徑前綴

### 5.4 修正 Meta.json

- Medium/Q007: difficulty 改為 "medium"（或移動到正確資料夾）
- Medium/Q008: difficulty 改為 "medium"
- Medium/Q010: difficulty 改為 "medium"

---

## 六、符合標準的題目清單

### Easy (✓ 全部符合)
- Q001 ~ Q010：單一檔案 bug ✓

### Medium (需新建)
- 目前無符合標準的 Medium 題目
- 需要創建涉及 2 個檔案的題目

### Hard (部分符合)
- Q005：3 檔案 (DisplayManagerService + LogicalDisplay + Display) ✓
- Q007：3 檔案 ✓
- 其餘需重分類

---

**審查完成**
