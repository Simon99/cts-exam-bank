# filesystem 注入點分布列表

**CTS 路徑**: `cts/tests/filesystem/`
**更新時間**: 2025-02-11
**版本**: v1.0.0

---

## 概覽

- **總注入點數**: 28
- **按難度分布**: Easy(10) / Medium(12) / Hard(6)
- **涵蓋測試類別**: RandomRWTest, SequentialRWTest, AlmostFullTest

---

## 對應 AOSP 源碼路徑

- `system/core/fs_mgr/fs_mgr.cpp` — 核心文件系統管理
- `system/core/fs_mgr/fs_mgr_format.cpp` — 文件系統格式化
- `system/core/fs_mgr/libfstab/fstab.cpp` — fstab 解析
- `frameworks/base/core/java/android/os/storage/StorageManager.java` — Java 層存儲管理
- `frameworks/base/core/java/android/os/storage/VolumeInfo.java` — 卷信息管理

---

## CTS 測試功能對應

| CTS Test Class | 測試重點 | 對應 CDD 要求 |
|----------------|----------|---------------|
| RandomRWTest | 隨機讀寫吞吐量 | 8.2/H-1-2, 8.2/H-1-4 |
| SequentialRWTest | 順序讀寫吞吐量 | 8.2/H-1-1, 8.2/H-1-3 |
| AlmostFullTest | 磁盤接近滿時的 I/O 行為 | — |

---

## 注入點清單

### 1. 文件系統檢查與掛載 (fs_mgr.cpp)

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| FS-001 | fs_mgr.cpp | should_force_check() | 139-144 | COND | Easy | AlmostFullTest |
| FS-002 | fs_mgr.cpp | umount_retry() | 146-161 | BOUND, CALC | Medium | SequentialRWTest |
| FS-003 | fs_mgr.cpp | check_fs() | 163-255 | COND, ERR | Medium | AlmostFullTest |
| FS-004 | fs_mgr.cpp | is_ext4_superblock_valid() | 281-285 | COND | Easy | SequentialRWTest |
| FS-005 | fs_mgr.cpp | read_ext4_superblock() | 289-316 | BOUND, ERR | Medium | RandomRWTest |
| FS-006 | fs_mgr.cpp | tune_quota() | 334-365 | COND, STATE | Medium | AlmostFullTest |
| FS-007 | fs_mgr.cpp | tune_reserved_size() | 368-403 | CALC, BOUND | Easy | AlmostFullTest |
| FS-008 | fs_mgr.cpp | tune_encrypt() | 406-451 | COND, STATE | Hard | SequentialRWTest |
| FS-009 | fs_mgr.cpp | tune_verity() | 501-530 | COND, STR | Medium | RandomRWTest |
| FS-010 | fs_mgr.cpp | tune_casefold() | 533-568 | COND | Easy | SequentialRWTest |
| FS-011 | fs_mgr.cpp | read_f2fs_superblock() | 623-649 | BOUND, COND | Medium | RandomRWTest |
| FS-012 | fs_mgr.cpp | prepare_fs_for_mount() | 736-796 | STATE, ERR | Hard | AlmostFullTest |
| FS-013 | fs_mgr.cpp | __mount() | 830-906 | COND, ERR | Hard | SequentialRWTest |

### 2. 文件系統格式化 (fs_mgr_format.cpp)

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| FS-014 | fs_mgr_format.cpp | get_dev_sz() | 40-52 | ERR, BOUND | Easy | AlmostFullTest |
| FS-015 | fs_mgr_format.cpp | format_ext4() | 54-109 | CALC, COND | Medium | SequentialRWTest |
| FS-016 | fs_mgr_format.cpp | format_f2fs() | 111-160 | COND, CALC | Medium | RandomRWTest |
| FS-017 | fs_mgr_format.cpp | fs_mgr_do_format() | 162-183 | COND | Easy | AlmostFullTest |

### 3. Fstab 解析 (fstab.cpp)

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| FS-018 | fstab.cpp | CalculateZramSize() | 75-83 | CALC | Easy | AlmostFullTest |
| FS-019 | fstab.cpp | ParseMountFlags() | 105-133 | STR, COND | Easy | SequentialRWTest |
| FS-020 | fstab.cpp | ParseFsMgrFlags() | 135-340 | STR, COND | Hard | RandomRWTest |
| FS-021 | fstab.cpp | ParseByteCount 解析 | 238-244 | CALC, BOUND | Medium | AlmostFullTest |

### 4. Java 層 StorageManager (StorageManager.java)

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| FS-022 | StorageManager.java | getUuidForPath() | 780-805 | COND, STR | Easy | SequentialRWTest |
| FS-023 | StorageManager.java | mountObb() | 658-675 | ERR, COND | Medium | RandomRWTest |
| FS-024 | StorageManager.java | unmountObb() | 743-756 | ERR | Easy | RandomRWTest |
| FS-025 | StorageManager.java | isObbMounted() | 758-766 | COND | Easy | SequentialRWTest |
| FS-026 | StorageManager.java | getVolumes() | 850-858 | ERR | Medium | AlmostFullTest |
| FS-027 | StorageManager.java | getWritablePrivateVolumes() | 861-874 | COND, STATE | Hard | AlmostFullTest |
| FS-028 | StorageManager.java | findVolumeByUuid() | 820-830 | STR, COND | Hard | SequentialRWTest |

---

## 注入類型說明

| 類型 | 說明 | 典型注入方式 |
|------|------|-------------|
| COND | 條件判斷 | 改變 if/else 條件、反轉邏輯運算符 |
| BOUND | 邊界檢查 | 修改邊界值、移除 null 檢查 |
| CALC | 數值計算 | 錯誤的運算符、單位轉換錯誤 |
| ERR | 錯誤處理 | 忽略錯誤返回值、錯誤的異常處理 |
| STATE | 狀態轉換 | 錯誤的狀態設定、遺漏狀態更新 |
| STR | 字串處理 | 字串比較錯誤、解析問題 |

---

## 難度分布詳情

### Easy (10 個)
適合入門題目，通常是單一檔案內的明顯錯誤。

- FS-001: should_force_check() 條件判斷
- FS-004: ext4 superblock 有效性檢查
- FS-007: reserved_size 計算
- FS-010: casefold 功能開關
- FS-014: 設備大小獲取錯誤處理
- FS-017: 格式化類型選擇
- FS-018: zram 大小計算
- FS-019: 掛載標誌解析
- FS-022: UUID 路徑查詢
- FS-024: OBB 卸載
- FS-025: OBB 掛載狀態檢查

### Medium (12 個)
需要理解跨函數邏輯，涉及 2 個相關區塊。

- FS-002: umount 重試邏輯
- FS-003: 文件系統檢查流程
- FS-005: ext4 superblock 讀取
- FS-006: quota 功能啟用
- FS-009: verity 功能設定
- FS-011: f2fs superblock 讀取
- FS-015: ext4 格式化參數
- FS-016: f2fs 格式化選項
- FS-021: 字節數解析
- FS-023: OBB 掛載流程
- FS-026: 卷列表獲取

### Hard (6 個)
涉及跨模組架構，需要理解系統設計。

- FS-008: 加密功能啟用（涉及多個子系統）
- FS-012: 掛載前準備（涉及 fsck、tune2fs 等）
- FS-013: mount 系統調用封裝（涉及重試、錯誤處理）
- FS-020: fstab 標誌完整解析（涉及多種標誌類型）
- FS-027: 可寫私有卷判斷（涉及卷狀態機）
- FS-028: UUID 查找（涉及卷管理架構）

---

## 建議出題策略

1. **覆蓋 CDD 要求**：優先選擇對應 CDD 8.2/H-1-* 系列的注入點
2. **難度平衡**：每次出題保持 Easy:Medium:Hard = 2:2:1 的比例
3. **功能多樣性**：涵蓋 Native (C++) 和 Framework (Java) 層
4. **避免重複**：同一函數不要連續出題

---

## 更新紀錄

| 版本 | 日期 | 變更內容 |
|------|------|----------|
| v1.0.0 | 2025-02-11 | 初版建立，完成 28 個注入點分析 |

---

**文件位置**: `~/develop_claw/cts-exam-bank/injection-points/tests/filesystem.md`
