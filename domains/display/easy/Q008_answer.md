# CTS 除錯練習題 DIS-E008 - 解答

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

**方法**: `generateDisplayUniqueId()`

**行數**: 約 227-230

## 問題程式碼

```java
static String generateDisplayUniqueId(String packageName, int uid,
        VirtualDisplayConfig config) {
    return UNIQUE_ID_PREFIX + packageName + ((config.getUniqueId() != null)
            ? (config.getUniqueId())  // BUG: 缺少 ":" 分隔符
            : ("," + uid + "," + config.getName() + "," + sNextUniqueIndex.getAndIncrement()));
}
```

## Bug 分析

### 問題描述
當 `config.getUniqueId()` 不為 null 時，缺少了冒號 (`:`) 分隔符，導致 packageName 和 uniqueId 直接連接在一起。

### 字串拼接結果對比

**正確結果** (有分隔符 `:`):
```
"virtual:" + "com.android.cts.display" + ":" + "private_test_display"
= "virtual:com.android.cts.display:private_test_display"
```

**錯誤結果** (缺少分隔符):
```
"virtual:" + "com.android.cts.display" + "private_test_display"
= "virtual:com.android.cts.displayprivate_test_display"
```

### 為什麼測試會失敗

1. **格式不一致**: Virtual display unique ID 有固定格式規範，`UNIQUE_ID_PREFIX + packageName + ":" + uniqueId`
2. **解析問題**: 其他組件可能依賴此格式來解析 packageName，缺少分隔符會導致解析失敗
3. **唯一性問題**: 不同的 packageName + uniqueId 組合可能產生相同的最終字串

## 修復方案

```java
static String generateDisplayUniqueId(String packageName, int uid,
        VirtualDisplayConfig config) {
    return UNIQUE_ID_PREFIX + packageName + ((config.getUniqueId() != null)
            ? (":" + config.getUniqueId())  // 修復: 加回 ":" 分隔符
            : ("," + uid + "," + config.getName() + "," + sNextUniqueIndex.getAndIncrement()));
}
```

## Patch

```diff
-            ? (config.getUniqueId())
+            ? (":" + config.getUniqueId())
```

## 學習重點

1. **字串拼接細節**: 在多段字串拼接時，分隔符容易被遺漏
2. **格式一致性**: ID 格式需要在不同分支保持一致的結構
3. **三元運算符陷阱**: 複雜的三元運算符可能隱藏細微的錯誤

## 相關知識

- **Virtual Display**: Android 的虛擬顯示功能，允許應用創建虛擬螢幕
- **Display Unique ID**: 每個顯示設備的唯一識別碼，用於系統管理和區分不同顯示器
- **UNIQUE_ID_PREFIX**: 虛擬顯示的 ID 前綴，通常為 "virtual:"
