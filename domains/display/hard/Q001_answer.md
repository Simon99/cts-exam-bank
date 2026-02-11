# DIS-H001: 答案與解析

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**方法**：`createVirtualDisplayInternal()` (約第 1596-1600 行)

## Bug 程式碼

```java
// Optimization: Only strip system decorations flag when necessary.
// If OWN_CONTENT_ONLY is set, the display won't mirror sensitive content anyway,
// so we can skip this check for better performance.
if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0
        && (flags & VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY) == 0) {
    flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

## 正確程式碼

```java
if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
    flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

## Bug 分析

### 錯誤的「優化」邏輯

開發者加入了一個看似合理的「效能優化」：

> 「如果 `OWN_CONTENT_ONLY` 被設置，display 不會 mirror 敏感內容，所以可以跳過 system decorations 檢查。」

這個推論是**錯誤的**，原因如下：

### 為什麼這是安全漏洞？

1. **`OWN_CONTENT_ONLY` 和 `SHOULD_SHOW_SYSTEM_DECORATIONS` 是獨立的安全屬性**
   - `OWN_CONTENT_ONLY`：控制 display 是否 mirror 其他 display 的內容
   - `SHOULD_SHOW_SYSTEM_DECORATIONS`：控制是否在此 display 上渲染狀態列、導航列

2. **即使不 mirror，system decorations 仍會被渲染**
   ```
   ┌─────────────────────────────────────┐
   │  VirtualDisplay (OWN_CONTENT_ONLY)  │
   │  ┌─────────────────────────────────┐│
   │  │  Status Bar (含敏感通知)         ││ ← 仍會渲染！
   │  ├─────────────────────────────────┤│
   │  │                                  ││
   │  │      App 自己的內容              ││
   │  │                                  ││
   │  ├─────────────────────────────────┤│
   │  │  Navigation Bar                  ││
   │  └─────────────────────────────────┘│
   └─────────────────────────────────────┘
   ```

3. **攻擊向量**
   ```java
   // 惡意 App 可以這樣做：
   DisplayManager dm = getSystemService(DisplayManager.class);
   VirtualDisplay vd = dm.createVirtualDisplay(
       "MaliciousDisplay",
       width, height, dpi,
       surface,
       DisplayManager.VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY |
       DisplayManager.VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS,
       callback, handler
   );
   // 現在可以從 surface 讀取 system decorations 的內容
   ```

### 安全模型被打破

```
原本的安全保證：
  untrusted display → 無條件清除 SHOULD_SHOW_SYSTEM_DECORATIONS

被破壞後：
  untrusted display + OWN_CONTENT_ONLY → 保留 SHOULD_SHOW_SYSTEM_DECORATIONS ❌
```

## 修復方案

移除錯誤的條件判斷，恢復無條件清除邏輯：

```diff
-        // Optimization: Only strip system decorations flag when necessary.
-        // If OWN_CONTENT_ONLY is set, the display won't mirror sensitive content anyway,
-        // so we can skip this check for better performance.
-        if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0
-                && (flags & VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY) == 0) {
-            flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
-        }
+        if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
+            flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
+        }
```

## 關鍵教訓

1. **安全檢查不能「優化」掉**：即使看起來某個路徑不需要檢查，安全檢查應該保持無條件執行

2. **獨立屬性不能混淆**：`OWN_CONTENT_ONLY`（內容來源）和 `SHOULD_SHOW_SYSTEM_DECORATIONS`（UI 渲染）解決不同的問題

3. **效能 vs 安全**：在安全關鍵路徑上，正確性永遠優先於效能

4. **註解可能是騙人的**：看起來合理的解釋不代表邏輯正確，要驗證假設

## CTS 測試原理

`testUntrustedSysDecorVirtualDisplay` 的測試邏輯：

```java
@Test
public void testUntrustedSysDecorVirtualDisplay() {
    // 以普通 app 身份建立 VirtualDisplay
    VirtualDisplay display = mDisplayManager.createVirtualDisplay(
        "TestDisplay",
        WIDTH, HEIGHT, DENSITY,
        mSurface,
        VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY |
        VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS,
        null, null
    );
    
    // 驗證 SHOULD_SHOW_SYSTEM_DECORATIONS 被正確清除
    Display.Mode mode = display.getDisplay().getMode();
    int actualFlags = display.getDisplay().getFlags();
    assertFalse(
        "Untrusted display should not have system decorations",
        (actualFlags & Display.FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS) != 0
    );
}
```

## 難度評估：Hard

- **需要理解跨模組關係**：VirtualDisplay flags、system decorations、安全模型
- **誤導性強**：註解看起來很合理，需要深入思考才能發現漏洞
- **安全意識要求高**：需要理解為什麼這是安全問題而非功能問題
