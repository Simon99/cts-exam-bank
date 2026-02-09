# M-Q008: VirtualDisplay FLAG 處理邏輯問題 - 答案

## Bug 分析

此題涉及兩個檔案中的協同 bug，導致不受信任的 VirtualDisplay 錯誤地顯示系統裝飾。

### Bug 1: DisplayManagerService.java - TRUSTED flag 條件反轉

**位置:** `services/core/java/com/android/server/display/DisplayManagerService.java`

```java
if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0) {  // [BUG] 應該是 == 0
    flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

**問題:** 
- 條件 `!= 0` 應該是 `== 0`
- 這導致從**受信任**的 VirtualDisplay 移除系統裝飾 flag
- 不受信任的 VirtualDisplay 反而保留了系統裝飾 flag

**安全影響:**
- 不受信任的 VirtualDisplay 顯示系統裝飾可能洩露敏感資訊
- 例如：通知內容、狀態欄資訊等

### Bug 2: VirtualDisplayAdapter.java - FLAG 設定條件反轉

**位置:** `services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

```java
if ((mFlags & VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS) == 0) {  // [BUG] 應該是 != 0
    mInfo.flags |= DisplayDeviceInfo.FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

**問題:**
- 條件 `== 0` 應該是 `!= 0`
- 這導致當 flag **未設定**時反而加上系統裝飾
- 與 Bug 1 結合，造成完全相反的行為

## 修復方案

### 修復 1: DisplayManagerService.java

```java
if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {  // 修復：不受信任時移除 flag
    flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

### 修復 2: VirtualDisplayAdapter.java

```java
if ((mFlags & VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS) != 0) {  // 修復：flag 設定時才加
    mInfo.flags |= DisplayDeviceInfo.FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

## 驗證

```bash
atest android.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay
```

## 學習重點

1. **安全性考量**: VirtualDisplay 的 flag 處理直接影響安全性
2. **TRUSTED flag 的意義**: 只有系統或有特權的應用才能創建 trusted VirtualDisplay
3. **位元運算**: `& ~FLAG` 用於清除 flag，`| FLAG` 用於設定 flag
4. **跨檔案邏輯一致性**: DisplayManagerService 和 VirtualDisplayAdapter 的 flag 處理必須協調一致

## 難度

**Medium** - 需要理解 VirtualDisplay 的安全模型和 flag 處理機制
