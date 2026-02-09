# Q006 答案

## Bug 描述

在 `VirtualDisplayAdapter.java` 中，設置 `FLAG_PRESENTATION` 時使用了錯誤的位元運算符。

## 問題代碼

```java
// 位置：VirtualDisplayAdapter.java 第 495 行
if ((mFlags & VIRTUAL_DISPLAY_FLAG_PRESENTATION) != 0) {
    mInfo.flags &= DisplayDeviceInfo.FLAG_PRESENTATION;  // ❌ 錯誤
}
```

## 修復代碼

```java
if ((mFlags & VIRTUAL_DISPLAY_FLAG_PRESENTATION) != 0) {
    mInfo.flags |= DisplayDeviceInfo.FLAG_PRESENTATION;  // ✅ 正確
}
```

## 原因分析

- `&=`（AND 賦值）：`flags &= FLAG_X` 只保留 flags 和 FLAG_X 共有的位元
  - 如果 flags 原本是 `0001`，FLAG_PRESENTATION 是 `0010`
  - 結果：`0001 & 0010 = 0000`（清除了原有的 flags！）
  
- `|=`（OR 賦值）：`flags |= FLAG_X` 添加 FLAG_X 到 flags
  - 如果 flags 原本是 `0001`，FLAG_PRESENTATION 是 `0010`
  - 結果：`0001 | 0010 = 0011`（正確添加了新 flag）

## 測試驗證

```bash
atest android.display.cts.VirtualDisplayTest#testPrivatePresentationVirtualDisplay
```

## 相關知識

1. **位元運算符**：
   - `|=`：添加 flag（OR）
   - `&=`：保留/清除 flag（AND）
   - `^=`：切換 flag（XOR）

2. **VirtualDisplay 架構**：
   - `VIRTUAL_DISPLAY_FLAG_PRESENTATION`：表示這是一個 Presentation 顯示
   - 會被轉換為 `DisplayDeviceInfo.FLAG_PRESENTATION`
