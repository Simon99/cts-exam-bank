# DIS-M006: 答案與解析

## 正確答案：A

## CTS 測試路徑

**測試方法：** `android.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay`

**呼叫鏈：**
1. `VirtualDisplayTest.testPrivateVirtualDisplay()`
   ```java
   VirtualDisplay virtualDisplay = mDisplayManager.createVirtualDisplay(NAME,
           WIDTH, HEIGHT, DENSITY, mSurface, 0);  // flags = 0
   ```
2. → `DisplayManager.createVirtualDisplay()` (`frameworks/base/core/java/android/hardware/display/DisplayManager.java`)
3. → `DisplayManagerGlobal.createVirtualDisplay()` (`frameworks/base/core/java/android/hardware/display/DisplayManagerGlobal.java`)
4. → `IDisplayManager.createVirtualDisplay()` (Binder IPC)
5. → `DisplayManagerService.createVirtualDisplayInternal()` (`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java:1450`)
6. → `DisplayManagerService.createVirtualDisplayLocked()` (Line 1729)
7. → `VirtualDisplayAdapter.createVirtualDisplayLocked()` (`frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java:116`)
8. → `new VirtualDisplayDevice(...)` (Line 135)
9. → `VirtualDisplayDevice.getDisplayDeviceInfoLocked()` (Line 460) ← **Bug 注入點**

**驗證點：**
```java
// VirtualDisplayTest.java Line 195
assertDisplayRegistered(display, Display.FLAG_PRIVATE);

// assertDisplayRegistered() 會呼叫：
assertEquals("display must have correct flags", flags, display.getFlags());
```

## 解析

### Bug 根因

原始正確程式碼：
```java
if ((mFlags & VIRTUAL_DISPLAY_FLAG_PUBLIC) == 0) {
    mInfo.flags |= DisplayDeviceInfo.FLAG_PRIVATE
            | DisplayDeviceInfo.FLAG_NEVER_BLANK;
}
```

錯誤程式碼（條件翻轉）：
```java
if ((mFlags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0) {  // ❌ 邏輯錯誤
    mInfo.flags |= DisplayDeviceInfo.FLAG_PRIVATE
            | DisplayDeviceInfo.FLAG_NEVER_BLANK;
}
```

### 問題分析

1. **Private vs Public Display 的判斷邏輯：**
   - 當 `VIRTUAL_DISPLAY_FLAG_PUBLIC` **沒有**被設定時（`== 0`），表示這是私有 display
   - 私有 display 應該設定 `FLAG_PRIVATE` 和 `FLAG_NEVER_BLANK`

2. **錯誤的影響：**
   - 條件從 `== 0` 改為 `!= 0` 後，邏輯完全翻轉
   - 現在只有 PUBLIC display 才會設定 `FLAG_PRIVATE`（這是錯誤的）
   - 私有 display 的 flags 保持為 0，沒有 `FLAG_PRIVATE` 標誌

3. **CTS 測試失敗原因：**
   - `testPrivateVirtualDisplay()` 傳入 `flags = 0`（無 PUBLIC flag）
   - 測試預期 `Display.FLAG_PRIVATE` (值為 4) 被設定
   - 實際上 flags 為 0，導致 assertEquals 失敗

### 為什麼其他選項錯誤

**B. 使用 `Display.FLAG_PRIVATE` 替代 `DisplayDeviceInfo.FLAG_PRIVATE`**
- 這兩個常數值相同，都是 4
- `DisplayDeviceInfo` 是 server 端使用，`Display` 是 client 端使用
- 在 server 端使用 `DisplayDeviceInfo` 的常數是正確的設計

**C. 需要檢查 `VIRTUAL_DISPLAY_FLAG_SECURE`**
- Private 和 Secure 是獨立的概念
- Private 表示只有建立者可以看到，Secure 表示內容受保護
- 私有 display 不一定需要是 secure 的

**D. 初始化為 `FLAG_PRIVATE`**
- 這樣所有 display（包括 public display）都會有 `FLAG_PRIVATE`
- 這會破壞 public display 的行為
- 正確做法是根據條件動態設定

## 修復方案

```java
// 修復：將 != 改回 ==
if ((mFlags & VIRTUAL_DISPLAY_FLAG_PUBLIC) == 0) {
    mInfo.flags |= DisplayDeviceInfo.FLAG_PRIVATE
            | DisplayDeviceInfo.FLAG_NEVER_BLANK;
}
```

## 知識點

1. **Virtual Display Flag 設計：** Android 使用 bit flags 組合表示 display 屬性
2. **Private vs Public Display：** Private display 只有建立者能存取，Public display 可以被其他 app 發現
3. **位元運算判斷：** `(flags & FLAG) == 0` 表示該 flag 未設定，`!= 0` 表示已設定
4. **條件邏輯翻轉錯誤：** 這是常見的邏輯 bug，特別是在重構或複製程式碼時容易發生

## 受影響的 CTS 測試

- `android.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay`
- `android.display.cts.VirtualDisplayTest#testPrivatePresentationVirtualDisplay`
- `android.display.cts.VirtualDisplayTest#testPrivateVirtualDisplayWithDynamicSurface`
- `android.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay`
