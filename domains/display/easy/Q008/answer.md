# 答案 - Display Flags 設置錯誤

## 問題分析

1. **錯誤訊息說明**：
   - 期望值 36 = 0x24 = FLAG_PRESENTATION (0x04) | FLAG_TRUSTED (0x20)
   - 實際值 32 = 0x20 = FLAG_TRUSTED
   - 缺少了 FLAG_PRESENTATION 標誌

2. **根本原因**：
   在 `OverlayDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中：
   ```java
   // 錯誤的代碼
   mInfo.flags = 0;  // 初始化時沒有設置 FLAG_PRESENTATION
   ```
   
   應該初始化為 `FLAG_PRESENTATION`，因為 overlay display 是用於 presentation 的顯示器。

## Bug 位置

**文件**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**方法**: `OverlayDisplayDevice.getDisplayDeviceInfoLocked()`

**行號**: 約第 352 行

## 修復方式

```java
// 修復後的代碼
mInfo.flags = DisplayDeviceInfo.FLAG_PRESENTATION;  // 正確初始化標誌
```

## 驗證修復

執行測試確認修復有效：
```bash
atest CtsDisplayTestCases:DisplayTest#testFlags
```

## 相關知識點

1. **FLAG_PRESENTATION (0x04)**：表示這是一個 presentation display，適合顯示投影或簡報內容
2. **FLAG_TRUSTED (0x20)**：表示這是一個受信任的顯示器，由系統創建
3. **位運算**：使用 `|` 運算符組合多個標誌

## 學習要點

- Display flags 使用位元標誌（bit flags）模式
- 初始化時要設置正確的基礎標誌
- 後續的 `|=` 操作是添加額外標誌，不會覆蓋已設置的
