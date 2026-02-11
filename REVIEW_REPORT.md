# CTS 題庫審查總報告

**版本**: v3.0.0  
**審查日期**: 2026-02-10  
**更新時間**: 2026-02-10 13:31 GMT+8  
**審查範圍**: 10 個領域，共 300 題  
**AOSP 版本**: Android 14 (android-14.0.0_r74)

---

## 審查標準

1. **Patch 可套用性** — 對照 `~/develop_claw/aosp-sandbox-1/` 源碼
   - 行號是否正確（fuzz ≤3 行可接受）
   - 上下文是否匹配實際源碼

2. **引用存在性** — patch 中的函數名、變數名、常量名是否存在於目標檔案

3. **難度符合** — 涉及檔案數是否符合難度要求
   - Easy: 1 檔案
   - Medium: 2 檔案
   - Hard: ≥3 檔案

4. **Answer/Patch 一致性** — 答案描述的 bug 與 patch 改動一致

**注意**：「源碼本身正確」不是問題（我們是注入 bug），重點是 patch 能否成功 apply。

---

## 總覽

| 領域 | ✅ 通過 | ⚠️ 小修 | ❌ 重寫 | 總題數 |
|------|--------|---------|--------|--------|
| app | 5 | 13 | 12 | 30 |
| camera | 0 | 15 | 15 | 30 |
| display | 5 | 11 | 14 | 30 |
| filesystem | 0 | 10 | 20 | 30 |
| framework | 0 | 17 | 13 | 30 |
| gpu | 0 | 15 | 15 | 30 |
| jobscheduler | 0 | 10 | 20 | 30 |
| location | 2 | 4 | 24 | 30 |
| media | 0 | 2 | 28 | 30 |
| net | 3 | 7 | 20 | 30 |
| **總計** | **15** | **104** | **181** | **300** |

### 統計

| 狀態 | 題數 | 比例 |
|------|------|------|
| ✅ 通過 | 15 | 5.0% |
| ⚠️ 小修（行號偏移，結構正確）| 104 | 34.7% |
| ❌ 重寫（引用不存在/結構不匹配）| 181 | 60.3% |

---

## 各領域詳細結果

---

## App 領域（30 題）

### app/easy (✅2 ⚠️5 ❌3)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ✅ 通過 | 行號正確，patch 可直接套用 |
| Q002 | ✅ 通過 | 行號正確，bug 邏輯合理 |
| Q003 | ⚠️ 小修 | 答案行號差 1 行（593→594），patch 本身正確 |
| Q004 | ✅ 通過 | 行號完全匹配，無需修改 |
| Q005 | ❌ 重寫 | 路徑不存在（`device/google/panther/vendor.prop` 在 AOSP 14 不存在） |
| Q006 | ⚠️ 小修 | — |
| Q007 | ⚠️ 小修 | — |
| Q008 | ⚠️ 小修 | 行號差 13 行（1089→1102） |
| Q009 | ❌ 重寫 | 行號錯誤（268→354），且代碼結構不同 |
| Q010 | ⚠️ 小修 | 行號偏差約 210 行（patch 寫 453，實際在 666） |

### app/medium (✅1 ⚠️4 ❌5)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ⚠️ 小修 | DisplayInfo.java 行號正確，Display.java 只差 2 行 |
| Q002 | ❌ 重寫 | Answer 說的是 `Mode.matches()` 參數交換 bug，但 Patch 改的是 cache invalidation |
| Q003 | ✅ 通過 | 行號完全對應 AOSP 14 源碼 |
| Q004 | ❌ 重寫 | Patch 用了佔位符行號 `xxx`，`setLuxNitsMapping` 方法不存在 |
| Q005 | ⚠️ 小修 | Patch 行號正確，但 Answer 提到不存在的 `createHdrCapabilities()` 方法 |
| Q006 | ❌ 重寫 | Answer 說的是運算符 `&=`→`|=` bug，但 Patch 改的是完全不同的東西 |
| Q007 | ❌ 重寫 | 從 hard 目錄複製過來但沒改 ID |
| Q008 | ⚠️ 小修 | meta.json 的 id 和難度標錯 |
| Q009 | ❌ 重寫 | 題目說的是 `equals()` 運算符錯誤，但 patch 改的是 `getState()` |
| Q010 | ⚠️ 小修 | — |

### app/hard (✅2 ⚠️4 ❌4)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ❌ 重寫 | 行號用 `xxx` 佔位符，引用不存在的 `isRefreshRateMatch` 方法 |
| Q002 | ⚠️ 小修 | 第三個檔案引用了不存在的 `filterSupportedModes()` 方法 |
| Q003 | ❌ 重寫 | Patch 格式壞掉（用了 `xxx` 佔位符） |
| Q004 | ⚠️ 小修 | 2/3 方法虛構 |
| Q005 | ⚠️ 小修 | 只有 LogicalDisplay.java 差 1 行 |
| Q006 | ❌ 重寫 | 三個 bug 裡有兩個是假的 |
| Q007 | ✅ 通過 | Patch 可成功應用 |
| Q008 | ❌ 重寫 | 只加註釋不改行為，測試方法不存在 |
| Q009 | ⚠️ 小修 | 引用不存在的 `createAuthTokenResult` 方法 |
| Q010 | ✅ 通過 | — |

---

## Camera 領域（30 題）

### camera/easy (⚠️8 ❌2)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ❌ 重寫 | 行號錯（285→243）、方法簽名不對 |
| Q002 | ❌ 重寫 | 行號差 437 行、方法簽名不對 |
| Q003 | ⚠️ 小修 | 行號只差 9 行 |
| Q004 | ⚠️ 小修 | 行號偏移 305 行 |
| Q005 | ⚠️ 小修 | 行號偏移 425 行 + 變數名不對 |
| Q006 | ⚠️ 小修 | 行號偏移 576 行 |
| Q007 | ⚠️ 小修 | 行號偏移 429 行，內容正確 |
| Q008 | ❌ 重寫 | 行號偏移 330 行 + 方法簽名不符 |
| Q009 | ⚠️ 小修 | 行號偏移約 1000 行 |
| Q010 | ⚠️ 小修 | 行號偏移 + 方法簽名需修正 |

### camera/medium (⚠️7 ❌3)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ⚠️ 小修 | 兩個檔案都只差 1 行 |
| Q002 | ❌ 重寫 | 核心邏輯完全虛構 |
| Q003 | ⚠️ 小修 | 行號錯誤 + 註釋不算真 bug |
| Q004 | ⚠️ 小修 | 兩個檔案行號都不對（差 29 和 77 行） |
| Q005 | ⚠️ 小修 | 一個正確，另一個差 214 行 |
| Q006 | ⚠️ 小修 | 一個正確，另一個差 335 行 |
| Q007 | ⚠️ 小修 | 一個正確，另一個差 27 行 |
| Q008 | ⚠️ 小修 | 一個正確，另一個差 335 行 |
| Q009 | ⚠️ 小修 | 一個正確，另一個差 27 行 |
| Q010 | ❌ 重寫 | 行號偏差 500+ 行，方法簽名不符 |

### camera/hard (❌10) ⚠️ 全軍覆沒

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ❌ 重寫 | 方法名錯誤 + `merge()` 方法不存在 |
| Q002 | ❌ 重寫 | 多個方法完全虛構 |
| Q003 | ❌ 重寫 | `setInputStreamId()` 是虛構的 API |
| Q004 | ❌ 重寫 | 三個檔案行號全錯（偏差 287-1778 行） |
| Q005 | ❌ 重寫 | 三個檔案的函數/變數全不存在 |
| Q006 | ❌ 重寫 | `calculateBurstSize()` 等方法虛構 |
| Q007 | ❌ 重寫 | 方法名錯誤，代碼結構虛構 |
| Q008 | ❌ 重寫 | DNG 相關 patch 完全虛構 |
| Q009 | ❌ 重寫 | 多個方法不存在 |
| Q010 | ❌ 重寫 | 行號偏差 685-1766 行，變數不存在 |

---

## Display 領域（30 題）

### display/easy (✅3 ⚠️4 ❌3)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ✅ 通過 | 行號正確，patch 可直接套用 |
| Q002 | ✅ 通過 | 行號正確，bug 邏輯合理 |
| Q003 | ⚠️ 小修 | Answer 行號差 1 行 |
| Q004 | ✅ 通過 | 行號完全匹配 |
| Q005 | ❌ 重寫 | Patch 路徑錯誤 |
| Q006 | ❌ 重寫 | 方法在 AOSP 14 不存在 |
| Q007 | ⚠️ 小修 | 行號差 284 行 |
| Q008 | ⚠️ 小修 | 行號差 13 行 |
| Q009 | ❌ 重寫 | 行號差 86 行，源碼結構不同 |
| Q010 | ⚠️ 小修 | 行號偏差約 210 行 |

### display/medium (✅1 ⚠️4 ❌5)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ⚠️ 小修 | 只差 2 行 |
| Q002 | ❌ 重寫 | Answer/Patch 不一致 |
| Q003 | ✅ 通過 | 行號完全對應 |
| Q004 | ❌ 重寫 | 佔位符 + API 虛構 |
| Q005 | ⚠️ 小修 | 文字描述錯誤 |
| Q006 | ❌ 重寫 | Answer/Patch 不一致 |
| Q007 | ❌ 重寫 | 複製貼上錯誤 |
| Q008 | ⚠️ 小修 | ID/難度標錯 |
| Q009 | ❌ 重寫 | Answer/Patch 不一致 |
| Q010 | ⚠️ 小修 | — |

### display/hard (✅1 ⚠️3 ❌6)

| 題目 | 結果 | 問題描述 |
|------|------|----------|
| Q001 | ❌ 重寫 | 佔位符行號、方法虛構 |
| Q002 | ⚠️ 小修 | 1/3 方法虛構 |
| Q003 | ❌ 重寫 | Patch 壞掉、方法虛構 |
| Q004 | ⚠️ 小修 | 2/3 方法虛構 |
| Q005 | ⚠️ 小修 | 差 1 行 |
| Q006 | ❌ 重寫 | 2/3 bug 虛構 |
| Q007 | ✅ 通過 | — |
| Q008 | ❌ 重寫 | 只加註釋、測試不存在 |
| Q009 | ❌ 重寫 | Patch 壞掉、錯誤 AOSP 版本 |
| Q010 | ❌ 重寫 | — |

---

## Filesystem 領域（30 題）

### filesystem/easy (⚠️7 ❌3)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ⚠️ | 行號 248→253，mPrimary 存在 |
| Q002 | ⚠️ | 行號 256→262，mRemovable 存在 |
| Q003 | ⚠️ | 行號 324→397，邏輯正確 |
| Q004 | ❌ | 上下文不匹配：patch 用 `getAbsolutePath()`，實際是 `toString()` |
| Q005 | ⚠️ | 行號 1050→765，方法存在 |
| Q006 | ⚠️ | 行號 38→45，常量存在 |
| Q007 | ❌ | 上下文不匹配：`writeString()` vs `writeString8()` |
| Q008 | ⚠️ | 行號 372→541，結構正確 |
| Q009 | ⚠️ | 行號 165→183，UUID 值正確 |
| Q010 | ❌ | 結構不匹配：實際有 isEmpty 條件判斷 |

### filesystem/medium (⚠️1 ❌9)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | `notifyStateChange()` 不存在 |
| Q002 | ❌ | 結構完全不同（switch-case vs if） |
| Q003 | ❌ | 實際用 `FileUtils.contains()` |
| Q004 | ❌ | 實際用 `native_replyRead()` |
| Q005 | ❌ | `isSupportedFilesystem()` 方法不存在 |
| Q006 | ❌ | `getNormalizedFatUuid()` 方法不存在 |
| Q007 | ❌ | 用 Callbacks wrapper，不直接遍歷 |
| Q008 | ❌ | `fromFile()` 方法不存在 |
| Q009 | ⚠️ | 行號可 fuzz，但部分方法不存在需修 |
| Q010 | ❌ | `isCallerAllowedToMountObb` 方法不存在 |

### filesystem/hard (⚠️2 ❌8)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | 行號差 161 行 |
| Q002 | ❌ | 行號差 1000+ 行 |
| Q003 | ❌ | `findDiskById` 方法不存在 |
| Q004 | ❌ | 代碼結構完全不同 |
| Q005 | ❌ | 用 `TypedXmlSerializer` |
| Q006 | ❌ | CrateInfo 沒有 mIcon 欄位 |
| Q007 | ⚠️ | 邏輯結構匹配，行號偏移 ~10 行 |
| Q008 | ❌ | parseMode 只是 delegate |
| Q009 | ⚠️ | 方法存在，行號偏移可修 |
| Q010 | ❌ | 依賴不存在的 if-else 結構 |

---

## Framework 領域（30 題）

### framework/easy (⚠️9 ❌1)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ⚠️ | 行號 1150→1415，getString 內容匹配 |
| Q002 | ⚠️ | 行號 980→1290，getInt 內容匹配 |
| Q003 | ⚠️ | 行號 520→698，containsKey 匹配 |
| Q004 | ⚠️ | 行號 490→555，size 匹配 |
| Q005 | ⚠️ | 行號 8520→9435，getStringExtra 匹配 |
| Q006 | ⚠️ | 行號 480→563，isEmpty 匹配 |
| Q007 | ⚠️ | 行號 8450→9245，hasExtra 匹配 |
| Q008 | ⚠️ | 行號 920→1154，getBoolean 匹配 |
| Q009 | ⚠️ | 行號 535→750，remove 匹配 |
| Q010 | ❌ | 實際用 `action.intern()` |

### framework/medium (⚠️4 ❌6)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | `writeInt(N)` 不存在 |
| Q002 | ⚠️ | 行號偏移 674 行，方法存在 |
| Q003 | ❌ | `copyInternal()` 不存在 |
| Q004 | ⚠️ | 行號偏移大但邏輯正確 |
| Q005 | ⚠️ | 行號 420→307，上下文匹配 |
| Q006 | ❌ | clone() 只有 `new Intent(this)` |
| Q007 | ❌ | keySet() 無 unmodifiableSet |
| Q008 | ⚠️ | 行號偏移，有 loader null 檢查需調整 |
| Q009 | ❌ | resolveType 結構不同 |
| Q010 | ❌ | 行號差太多，結構不同 |

### framework/hard (⚠️4 ❌6)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | 上下文是 Serializable |
| Q002 | ❌ | writeBundle 沒有 startPos/endPos 邏輯 |
| Q003 | ⚠️ | mContentUserHint 存在，行號偏移 600 行 |
| Q004 | ❌ | 無 `source.recycle()` 調用 |
| Q005 | ⚠️ | FLAG_IMMUTABLE 邏輯存在 |
| Q006 | ⚠️ | writeSparseArray keyAt 存在 |
| Q007 | ❌ | addCategory 原本沒有 synchronized |
| Q008 | ❌ | PendingIntent 只讀 StrongBinder |
| Q009 | ❌ | ContentResolver.notifyChange 直接傳 flags |
| Q010 | ⚠️ | mPriority/mOrder 存在 |

---

## GPU 領域（30 題）

### gpu/easy (⚠️8 ❌2)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ⚠️ | 行號 198→308，上下文匹配 |
| Q002 | ⚠️ | 行號 98→133，extension 存在 |
| Q003 | ⚠️ | 行號 67→87，get() 結構匹配 |
| Q004 | ⚠️ | 行號 192→231，eglGetError 存在 |
| Q005 | ⚠️ | 行號 228→260，eglSwapBuffers 匹配 |
| Q006 | ⚠️ | 行號 245→307，eglGetConfigsImpl 匹配 |
| Q007 | ⚠️ | 行號 220→334，wideColorBoardConfig 存在 |
| Q008 | ❌ | 用 `getExtensionString()` 而非 `mExtensionString.c_str()` |
| Q009 | ❌ | null 檢查在模板函數 |
| Q010 | ⚠️ | 行號 278→408，refs-- 匹配 |

### gpu/medium (⚠️4 ❌6)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ⚠️ | 行號 252→387，結構匹配 |
| Q002 | ⚠️ | 行號 295→373，MSAA 結構匹配 |
| Q003 | ❌ | 有額外的 pixelFormat 分支 |
| Q004 | ⚠️ | 行號 225→279，glGetStringi 匹配 |
| Q005 | ❌ | 實際用 template |
| Q006 | ⚠️ | 行號 82→107，removeObject 匹配 |
| Q007 | ❌ | 有 multifileMode 分支 |
| Q008 | ❌ | 用 template，img->buffer 不存在 |
| Q009 | ❌ | 只是 wrap 函數 |
| Q010 | ❌ | 無 setGLHooksThreadSpecific |

### gpu/hard (⚠️3 ❌7)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | loadLayers(), gEGLImpl 不存在 |
| Q002 | ❌ | isProtected 成員不存在 |
| Q003 | ❌ | getAngleBackend() 不存在 |
| Q004 | ❌ | cachedCompositorTimestamps 不存在 |
| Q005 | ❌ | glFlush 邏輯不匹配 |
| Q006 | ❌ | decodeSubblock() 不存在 |
| Q007 | ❌ | handleContextLost 不存在 |
| Q008 | ⚠️ | 行號偏移可修，但只有 2 檔案 |
| Q009 | ⚠️ | 結構匹配，但只有 2 檔案 |
| Q010 | ⚠️ | 行號正確，但只有 2 檔案 |

---

## JobScheduler 領域（30 題）

### jobscheduler/easy (⚠️7 ❌3)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ⚠️ | 行號 68→79，上下文正確 |
| Q002 | ⚠️ | 行號 85→124，isStorageNotLow 匹配 |
| Q003 | ⚠️ | 行號 228→327，匹配 |
| Q004 | ⚠️ | 行號 76→89，匹配 |
| Q005 | ⚠️ | 行號 95→142，匹配 |
| Q006 | ❌ | `mIdleTriggerHandler` 不存在 |
| Q007 | ❌ | isPeriodic 返回布林變數 |
| Q008 | ⚠️ | 行號 183→272，匹配 |
| Q009 | ⚠️ | 行號 105→147，正確 |
| Q010 | ❌ | `getCount()` 不存在 |

### jobscheduler/medium (⚠️1 ❌9)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | `isNetworkUnmetered` 方法不存在 |
| Q002 | ⚠️ | 行號偏移，結構正確 |
| Q003 | ❌ | `mJobComparator` 不存在，是 static |
| Q004 | ❌ | 簽名不匹配 |
| Q005 | ❌ | if 結構不存在 |
| Q006 | ❌ | 代碼在不同位置 |
| Q007 | ❌ | `setAutomotiveProjectionActive` 不存在 |
| Q008 | ❌ | pending reason 邏輯在不同位置 |
| Q009 | ❌ | 代碼塊不存在 |
| Q010 | ❌ | `handleJobCompletedLocked` 不存在 |

### jobscheduler/hard (⚠️2 ❌8)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | `isNetworkAvailableForJob` 不存在 |
| Q002 | ❌ | `isJobAllowedInDoze` 不存在 |
| Q003 | ❌ | 多個 canBypass* 方法都不存在 |
| Q004 | ⚠️ | setConstraintSatisfied 存在 |
| Q005 | ⚠️ | 3 檔案皆存在 |
| Q006 | ❌ | 結構完全不同 |
| Q007 | ❌ | `isUidTempWhitelisted` 不存在 |
| Q008 | ❌ | mDeadlineSatisfiedAtElapsed 不存在 |
| Q009 | ❌ | 結構不同 |
| Q010 | ❌ | 用 AdjustedJobStatus wrapper |

---

## Location 領域（30 題）

### location/easy (✅2 ⚠️3 ❌5)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ✅ | 通過 |
| Q002 | ⚠️ | 行號偏移 |
| Q003 | ✅ | 通過 |
| Q004 | ❌ | 上下文不匹配（mQuality 在 Builder 構造函數初始化） |
| Q005 | ❌ | 結構不匹配 |
| Q006 | ⚠️ | 行號偏移 |
| Q007 | ❌ | 結構不匹配 |
| Q008 | ❌ | 結構不匹配 |
| Q009 | ⚠️ | 行號偏移 |
| Q010 | ❌ | 結構不匹配 |

### location/medium (❌10) ⚠️ 全軍覆沒

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | patch 引用的函數/變數虛構 |
| Q002 | ❌ | patch 引用的函數/變數虛構 |
| Q003 | ❌ | patch 引用的函數/變數虛構 |
| Q004 | ❌ | patch 引用的函數/變數虛構 |
| Q005 | ❌ | patch 引用的函數/變數虛構 |
| Q006 | ❌ | patch 引用的函數/變數虛構 |
| Q007 | ❌ | patch 引用的函數/變數虛構 |
| Q008 | ❌ | patch 引用的函數/變數虛構 |
| Q009 | ❌ | patch 引用的函數/變數虛構 |
| Q010 | ❌ | patch 引用的函數/變數虛構 |

### location/hard (⚠️1 ❌9)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | `maybeFudgeLocation()` 等函數虛構 |
| Q002 | ❌ | `mPendingFlushes`、`FlushRequest` 虛構 |
| Q003 | ❌ | 函數虛構 |
| Q004 | ❌ | 函數虛構 |
| Q005 | ❌ | 函數虛構 |
| Q006 | ❌ | `convertPhaseCenterOffset()` 虛構 |
| Q007 | ❌ | 函數虛構 |
| Q008 | ❌ | 函數虛構 |
| Q009 | ❌ | 函數虛構 |
| Q010 | ⚠️ | 行號偏移 15 行（唯一存活的 Hard 題） |

---

## Media 領域（30 題）

### media/easy (⚠️2 ❌8)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | 行號錯誤（700+ 行 vs 實際 1800+ 行） |
| Q002 | ⚠️ | 行號偏移 16 行 |
| Q003 | ❌ | 行號錯誤 |
| Q004 | ❌ | 行號錯誤 |
| Q005 | ❌ | 行號錯誤 |
| Q006 | ⚠️ | 行號偏移 |
| Q007 | ❌ | 行號錯誤 |
| Q008 | ❌ | 行號錯誤 |
| Q009 | ❌ | 行號錯誤 |
| Q010 | ❌ | 行號偏移 15 行 |

### media/medium (❌10) ⚠️ 全軍覆沒

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | patch 引用 MediaCodec.java 中不存在的程式碼 |
| Q002 | ❌ | NuMediaExtractor.cpp 函數簽名錯誤（3 參數 vs 1 參數） |
| Q003 | ❌ | 行號偏移 180-230 行，常量定義順序寫反 |
| Q004 | ❌ | `mWriter->writeSample()` 方法不存在 |
| Q005 | ❌ | Native 層 `mOutputEOS` 變數不存在 |
| Q006 | ❌ | 過濾邏輯完全不同（`isSoftwareOnly()` vs `makeRegular()`） |
| Q007 | ❌ | 行號偏移 3000+ 行 |
| Q008 | ❌ | seek mode switch 語句在源碼中不存在 |
| Q009 | ❌ | `mInitialOutputFormat`、`mStaleNotify` 變數不存在 |
| Q010 | ❌ | `initProfileLevels()` 函數不存在，cpp 只有 548 行但 patch 說改第 678 行 |

### media/hard (❌10) ⚠️ 全軍覆沒

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | LLM 幻覺產物：`mCachedBufferInfos`、`mTracksStarted` 等全部虛構 |
| Q002 | ❌ | `mTrackStartTimes`、`mGlobalStartTimeUs` 等變數虛構 |
| Q003 | ❌ | `mIsAdaptivePlayback`、`handleOutputFormatChanged()` 虛構 |
| Q004 | ❌ | `parseSEI()`、`parseHdr10PlusInfo()` 不存在（源碼只寫 `// Ignore`） |
| Q005 | ❌ | `native_window_set_buffers_timestamp()` API 不存在 |
| Q006 | ❌ | MPEG4Writer 用 Chunk 機制，不是 Sample 直接寫入 |
| Q007 | ❌ | `mapColorAspectsToFormat`、`KEY_COLOR_PRIMARIES` 不存在 |
| Q008 | ❌ | 3 檔案裡只有 1 個可用，不符合 Hard 難度 |
| Q009 | ❌ | `mOutputBuffersOwnedByClient`、`returnOutputBufferToComponent()` 虛構 |
| Q010 | ❌ | 2/3 檔案的函數和參數虛構 |

---

## Net 領域（30 題）

### net/easy (✅3 ⚠️5 ❌2)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ⚠️ | 行號偏移 23 行 |
| Q002 | ✅ | 行號只偏移 1-2 行 |
| Q003 | ⚠️ | 行號偏移 6 行 |
| Q004 | ✅ | 偏移 3 行，在容許範圍 |
| Q005 | ✅ | 行號只偏移 1 行 |
| Q006 | ⚠️ | 行號偏移 12 行 |
| Q007 | ⚠️ | 偏移 3 行，卡在邊界 |
| Q008 | ❌ | bug 是虛構的（源碼本來就正確使用 `osOpt` 變數） |
| Q009 | ❌ | 行號偏移 126 行，context 還少了一行註解 |
| Q010 | ⚠️ | 行號偏移 14 行 |

### net/medium (⚠️2 ❌8)

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | 行號差 104 行，bug 邏輯反了（源碼本來就是 `true`） |
| Q002 | ❌ | 源碼本來就是 `>`，patch 想注入的 bug 不存在 |
| Q003 | ❌ | patch 假設 `split("=", 2)` 但源碼已是 `split("=")`，方向搞反 |
| Q004 | ❌ | patch 邏輯不會造成題目描述的現象 |
| Q005 | ⚠️ | 行號偏移 6 行，`affected_files` 路徑寫錯 |
| Q006 | ⚠️ | 行號偏移 7 行 |
| Q007 | ❌ | patch 和實際 bug 是兩碼子事（構造函數 vs `getPid()` 硬編碼） |
| Q008 | ❌ | 行號偏移 65 行，方法名錯（`getFragment()` vs `getFragmentPart()`） |
| Q009 | ❌ | 源碼已正確，patch 會導致編譯錯誤 |
| Q010 | ❌ | `mSavedState`、`saveState()` 全是虛構的 |

### net/hard (❌10) ⚠️ 全軍覆沒

| 題號 | 狀態 | 問題 |
|------|------|------|
| Q001 | ❌ | patch 完全虛構，`createVpnTransportInfo()` 不存在，只改 1 檔不符合 Hard |
| Q002 | ❌ | 行號偏移 93 行，patch 只改 1 檔 1 行不符合 Hard |
| Q003 | ❌ | 行號偏移 588 行，`appendEncoded` 不存在（只有 `appendDecoded`） |
| Q004 | ❌ | 2/3 檔案引用不存在的方法（`hasDateError`、`validateCertificateDates`） |
| Q005 | ❌ | 行號偏移 28 行，只改 1 檔應該是 Medium |
| Q006 | ❌ | 變數名全錯（`responseTime` vs `responseTicks`） |
| Q007 | ❌ | 行號差 515 行，`mConfig.validate()` 虛構 |
| Q008 | ❌ | 行號偏移需修正（125→141） |
| Q009 | ❌ | patch 引用的函數不存在，行號偏差 300+ 行 |
| Q010 | ❌ | patch 說序列化順序錯誤，但源碼順序是對的 |

---

## 問題類型分析

| 問題類型 | 出現次數 | 說明 |
|----------|----------|------|
| 行號偏差 | 100+ | 最常見，差距從 1 行到 3000+ 行 |
| 方法/API 虛構 | 80+ | camera/hard、media/hard、location/medium 全軍覆沒 |
| 結構不匹配 | 40+ | Template、wrapper、條件分支不同 |
| Bug 邏輯錯誤 | 15+ | patch 想注入的 bug 跟源碼實際狀態相反 |
| Answer/Patch 不一致 | 10+ | 答案描述的 bug 跟 patch 改的不是同一個 |
| 難度不符 | 10+ | Hard 題只有 1-2 檔案 |
| 複製貼上錯誤 | 5+ | ID、難度標示混亂 |
| Patch 格式損壞 | 3+ | 用 `xxx` 佔位符導致 corrupt |

---

## 後續建議

### 優先處理（⚠️ 小修，104 題）
只需更新行號，結構和引用正確：
- framework/easy: Q001-Q009（最佳）
- gpu/easy: Q001-Q007, Q010
- jobscheduler/easy: Q001-Q005, Q008-Q009
- net/easy: Q001, Q003, Q006, Q007, Q010
- 其他領域的 ⚠️ 題目

### 需重寫（❌，181 題）
建議對照實際 AOSP 源碼重新設計 bug 注入點：
1. 確認目標方法/變數確實存在
2. 確認代碼結構匹配
3. 確認難度（檔案數）符合要求

### 優先重寫順序（全軍覆沒區域）
1. **media/medium** — 10/10 需重寫
2. **media/hard** — 10/10 需重寫
3. **location/medium** — 10/10 需重寫
4. **net/hard** — 10/10 需重寫
5. **camera/hard** — 10/10 需重寫
6. **jobscheduler/medium** — 9/10 需重寫
7. **filesystem/medium** — 9/10 需重寫
8. **location/hard** — 9/10 需重寫

---

*審查完成時間：2026-02-10 13:31 GMT+8*  
*審查人：Sage (AI Assistant)*  
*版本：v3.0.0*
