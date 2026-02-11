# CTS 面試題目 DIS-E005 - 解答

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

**位置**: VirtualDisplayDevice constructor（約第 294 行）

## Bug 描述

在 `VirtualDisplayDevice` 的建構子中，`mDisplayState` 被錯誤地初始化為 `Display.STATE_OFF` 而非正確的 `Display.STATE_UNKNOWN`：

```java
// 錯誤的程式碼
mDisplayState = Display.STATE_OFF;

// 正確的程式碼
mDisplayState = Display.STATE_UNKNOWN;
```

## 原因分析

### 1. Display 狀態的語義

- **`Display.STATE_UNKNOWN` (0)**: 表示顯示器狀態尚未確定，是虛擬顯示器的正確初始狀態
- **`Display.STATE_OFF` (1)**: 表示顯示器明確處於關閉狀態

### 2. 為什麼初始值應該是 STATE_UNKNOWN

當 VirtualDisplay 剛被建立時：
- 系統尚未開始追蹤其實際狀態
- Surface 可能為 null，但這不代表顯示器「關閉」
- `STATE_UNKNOWN` 正確表達了「狀態尚未確定」的語義

### 3. Bug 對 CTS 測試的影響

`testPrivateVirtualDisplay` 驗證新建立的 virtual display 初始狀態：
- 預期: `STATE_UNKNOWN` (語義正確)
- 實際: `STATE_OFF` (錯誤的初始值)
- 結果: assertion 失敗

## 修復方案

```diff
-            mDisplayState = Display.STATE_OFF;
+            mDisplayState = Display.STATE_UNKNOWN;
```

## 關鍵學習點

1. **狀態初始化要符合語義**: `UNKNOWN` 表示尚未確定，`OFF` 表示明確關閉，這兩者語義不同
2. **Virtual Display 生命週期**: 建構時狀態未知，之後由系統根據實際情況更新
3. **CTS 測試的作用**: 確保 API 行為符合文件規範，包含初始狀態的驗證

## 延伸思考

1. 如果將初始狀態設為 `STATE_ON` 會有什麼影響？
2. `mIsDisplayOn` 與 `mDisplayState` 有什麼關係？為什麼分開追蹤？
3. 什麼時候 `mDisplayState` 會從 `STATE_UNKNOWN` 轉換為其他狀態？
