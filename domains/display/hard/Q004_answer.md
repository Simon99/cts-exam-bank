# CTS 題目解答：Display Mode 支援清單不完整

## 🐛 Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`  
**行號**: 約 470-479 行  
**方法**: `updateLocked()`

## 🔍 Bug 分析

### 原始正確代碼

```java
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes, deviceInfo.supportedModes.length);
```

### 引入的 Bug 代碼

```java
// Calculate effective modes count considering array bounds
int modesCount = deviceInfo.supportedModes.length;
// Ensure we don't exceed array capacity when there are many modes
int effectiveCount = modesCount > 1
        ? Math.min(modesCount - 1, deviceInfo.supportedModes.length)
        : modesCount;
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes,
        effectiveCount);
```

### Bug 類型

- **CALC (計算錯誤)**: `effectiveCount` 計算邏輯錯誤
- **BOUND (邊界錯誤)**: Off-by-one error，導致少複製一個 mode

### 根本原因

這個 bug 是一個隱蔽的 off-by-one 錯誤，偽裝成「邊界檢查」：

1. 當 `modesCount > 1` 時，計算 `effectiveCount = Math.min(modesCount - 1, modesCount)`
2. 由於 `modesCount - 1 < modesCount` 恆成立，`effectiveCount` 永遠等於 `modesCount - 1`
3. 這導致 `Arrays.copyOf()` 只複製前 N-1 個 modes，最後一個 mode 被遺漏

### 為什麼這個 Bug 很難發現

1. **有欺騙性的註解**: 註解說「Ensure we don't exceed array capacity」，讓人以為是安全檢查
2. **條件觸發**: 只有當設備支援超過 1 個 mode 時才觸發
3. **Math.min 掩護**: 使用 `Math.min()` 讓代碼看起來像是合理的邊界保護
4. **單一 mode 設備正常**: 在只有一個 mode 的設備上完全正常運作

## 📊 觸發條件

| 條件 | 結果 |
|------|------|
| `supportedModes.length == 1` | ✅ 正常（effectiveCount = 1） |
| `supportedModes.length == 2` | ❌ 只複製 1 個 mode |
| `supportedModes.length == 3` | ❌ 只複製 2 個 mode |
| `supportedModes.length == N` | ❌ 只複製 N-1 個 mode |

## 🧪 CTS 測試失敗原因

`testGetSupportedModesOnDefaultDisplay` 測試執行以下驗證：

1. **取得所有 supportedModes**
2. **對每個 mode 的 alternativeRefreshRates 進行驗證**
3. **使用 Union-Find 演算法檢查對稱性**

當最後一個 mode（假設是 120Hz）被遺漏時：
- Mode(60Hz) 的 alternativeRefreshRates 可能包含 [90.0, 120.0]
- Mode(90Hz) 存在於 supportedModes 中 ✓
- Mode(120Hz) 不存在於 supportedModes 中 ✗

測試無法在 supportedModes 中找到 refreshRate=120.0 的 mode，導致斷言失敗。

## ✅ 修復方案

還原為正確的陣列複製邏輯：

```java
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes, deviceInfo.supportedModes.length);
```

完全不需要額外的邊界計算，`Arrays.copyOf()` 本身就是安全的。

## 🎓 學習要點

1. **警惕「安全檢查」代碼**: 並非所有看起來像邊界檢查的代碼都是正確的
2. **注意 off-by-one**: `length - 1` 在陣列操作中是高風險模式
3. **理解 API 合約**: `Arrays.copyOf()` 的第二個參數是新陣列長度，不是索引
4. **追蹤數據流**: supportedModes 從 DeviceInfo 流向 DisplayInfo，任何遺漏都會破壞一致性
5. **多 mode 設備測試**: 單一 mode 設備無法發現此類 bug
