# CTS 題庫審查報告 - GPU + Filesystem 領域

**審查日期：** 2025-02-10
**審查範圍：** gpu/, filesystem/ 各難度共 60 題
**審查人：** Clawdbot (sub-agent)

---

## 📊 審查總結

| 領域 | 難度 | 題數 | 路徑正確 | 難度符合 | 需修正 |
|------|------|------|----------|----------|--------|
| GPU | Easy | 10 | ✅ 10/10 | ✅ 10/10 | 0 |
| GPU | Medium | 10 | ✅ 10/10 | ✅ 10/10 | 0 |
| GPU | Hard | 10 | ⚠️ 9/10 | ✅ 10/10 | 1 (已修正) |
| Filesystem | Easy | 10 | ✅ 10/10 | ✅ 10/10 | 0 |
| Filesystem | Medium | 10 | ⚠️ 9/10 | ❌ 0/10 | 10 (路徑已修正) |
| Filesystem | Hard | 10 | ⚠️ 8/10 | ⚠️ 3/10 | 9 (路徑已修正) |

---

## ✅ 已修正的問題

### 1. 路徑錯誤修正

| 題目 | 原路徑 | 正確路徑 | 狀態 |
|------|--------|----------|------|
| filesystem/medium/Q008 | `.../services/core/.../StorageStatsService.java` | `.../services/usage/.../StorageStatsService.java` | ✅ 已修正 |
| filesystem/hard/Q009 | `.../services/core/.../StorageStatsService.java` | `.../services/usage/.../StorageStatsService.java` | ✅ 已修正 |
| gpu/hard/Q006 | `graphics/jni/android_opengl_ETC1.cpp` | (不存在，已替換為其他檔案) | ✅ 已修正 |
| filesystem/hard/Q010 | `core/jni/android_security_FileIntegrity.cpp` | `.../security/FileIntegrity.java` | ✅ 已修正 |

### 2. 不存在檔案的替換

| 題目 | 原檔案 | 替換方案 |
|------|--------|----------|
| gpu/hard/Q006 | `android_opengl_ETC1.cpp` | 改用 `ETC1Util.java` + `egl_platform_entries.cpp` |
| filesystem/hard/Q010 | `android_security_FileIntegrity.cpp` | 改用 `FileIntegrity.java` |

---

## ⚠️ 難度定義不符（待重設計）

**難度定義標準：**
- Easy: 單一檔案，log 直接指向問題
- Medium: 2 個檔案，log 在 A 但 bug 在 B
- Hard: 3+ 個檔案，呼叫鏈或多處 bug

### Filesystem Medium（10 題全部不符）

這些題目的 patch 只涉及 **1 個檔案**，應為 Easy 難度或需重設計：

| 題目 | 當前涉及檔案 | 建議 |
|------|-------------|------|
| Q001 | StorageManagerService.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q002 | StorageManagerService.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q003 | StorageManager.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q004 | FuseAppLoop.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q005 | StorageManager.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q006 | StorageManager.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q007 | StorageManagerService.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q008 | StorageStatsService.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q009 | FileUtil.java (1) | 降級為 Easy 或增加跨檔案追蹤 |
| Q010 | StorageManagerService.java (1) | 降級為 Easy 或增加跨檔案追蹤 |

### Filesystem Hard（7 題不符）

這些題目的 patch 只涉及 **1 個檔案**，應為 Easy 難度或需重設計：

| 題目 | 當前涉及檔案 | meta.json 宣稱 | 實際 patch | 建議 |
|------|-------------|---------------|-----------|------|
| Q001 | StorageVolume.java | 3 | 1 | 重設計或降級 |
| Q002 | VolumeInfo.java | 1 | 1 | 降級為 Easy |
| Q003 | DiskInfo.java | 1 | 1 | 降級為 Easy |
| Q004 | StorageManager.java | 1 | 1 | 降級為 Easy |
| Q005 | VolumeRecord.java | 1 | 1 | 降級為 Easy |
| Q006 | CrateInfo.java | 1 | 1 | 降級為 Easy |
| Q007 | VolumeInfo.java | 1 | 1 | 降級為 Easy |
| Q008 | 3 個檔案 | 3 | 3 | ✅ 符合 |
| Q009 | 3 個檔案 | 3 | 3 | ✅ 符合 |
| Q010 | 3 個檔案 | 3 | 3 | ✅ 符合 |

---

## 📝 建議行動

### 短期（立即）
- [x] 修正路徑錯誤
- [x] 替換不存在的檔案

### 中期（需要重設計）
1. **Filesystem Medium 重設計方案：**
   - 方案 A：將這 10 題全部降級為 Easy
   - 方案 B：重新設計，加入跨檔案追蹤邏輯（如 API → Service → Implementation）

2. **Filesystem Hard Q001-Q007 重設計方案：**
   - 方案 A：降級為 Easy
   - 方案 B：擴展 bug 到多個檔案（如 Parcelable 的讀寫分離到不同類別）

### 推薦重設計模式

**Medium 難度標準模式：**
```
Log 出現在: frameworks/base/core/java/.../StorageManager.java
Bug 實際在: frameworks/base/services/core/java/.../StorageManagerService.java
```

**Hard 難度標準模式：**
```
Log 出現在: CTS Test (CtsOsTestCases)
↓
第一層: frameworks/base/core/java/.../StorageManager.java
↓
第二層: frameworks/base/services/core/java/.../StorageManagerService.java
↓
Bug 實際在: frameworks/base/core/java/.../VolumeInfo.java
```

---

## 🔍 驗證命令

```bash
# 驗證所有路徑是否存在
cd ~/develop_claw/aosp-sandbox-1
for patch in ~/develop_claw/cts-exam-bank/domains/*/[ehm]*/*_bug.patch; do
  grep "^diff --git" "$patch" | awk '{print $3}' | sed 's|a/||' | while read f; do
    [ -f "$f" ] || echo "MISSING: $f (from $patch)"
  done
done
```

---

**審查完成時間：** 2025-02-10
