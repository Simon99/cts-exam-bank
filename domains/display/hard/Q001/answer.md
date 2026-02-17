# DIS-H001: 答案與解析

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**方法**：`createVirtualDisplayInternal()` (約第 1593-1600 行)

## Bug 程式碼

```java
// BUG: Security check disabled - untrusted displays can now show system decorations
// Original code:
// if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
//     flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
// }
```

## 正確程式碼

```java
if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
    flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

## Bug 分析

### 安全檢查被完全移除

原本的安全邏輯是：**untrusted display 必須無條件清除 `SHOULD_SHOW_SYSTEM_DECORATIONS` flag**。

這段程式碼被註解掉了，導致：

1. Untrusted app 請求建立 VirtualDisplay，帶有 `SHOULD_SHOW_SYSTEM_DECORATIONS` flag
2. Flag 清除邏輯被跳過（因為被註解）
3. Flag 保留在 flags 中
4. 後續程式碼檢查到這個 flag，要求 `INTERNAL_SYSTEM_WINDOW` 權限
5. 普通 app 沒有此權限 → 拋出 `SecurityException`

### 程式碼流程

```
┌─────────────────────────────────────────────────────────────┐
│  createVirtualDisplayInternal()                             │
├─────────────────────────────────────────────────────────────┤
│  1. App 傳入 flags = SHOULD_SHOW_SYSTEM_DECORATIONS         │
│       ↓                                                      │
│  2. [被註解] 清除 SHOULD_SHOW_SYSTEM_DECORATIONS            │
│       ↓ (flag 未被清除)                                      │
│  3. 檢查：if (flags & SHOULD_SHOW_SYSTEM_DECORATIONS)       │
│       → 要求 INTERNAL_SYSTEM_WINDOW 權限                    │
│       ↓                                                      │
│  4. App 沒有權限 → SecurityException                        │
└─────────────────────────────────────────────────────────────┘
```

### 為什麼這是安全問題？

雖然最終結果是拋出 Exception（阻止了攻擊），但這破壞了 API 的預期行為：

**正常行為**：
- Untrusted app 請求 system decorations → flag 被靜默清除 → VirtualDisplay 正常建立（無 system decorations）

**Bug 行為**：
- Untrusted app 請求 system decorations → flag 未清除 → SecurityException → 無法建立 VirtualDisplay

這導致：
1. **功能退化**：原本可以正常建立的 VirtualDisplay 現在會失敗
2. **相容性問題**：依賴此 API 的 app 會 crash
3. **測試失敗**：CTS 預期靜默清除，而非拋出 Exception

### 兩層防禦設計

Android 的安全模型使用**防禦深度**：

```
第一層：Flag 清除（預防性）
  └── 在 flags 被使用前，先清除敏感 flags
  └── 優雅處理，不影響 app 功能

第二層：權限檢查（保險性）
  └── 如果 flag 意外保留，用權限檢查擋住
  └── 會拋出 Exception，影響 app 功能
```

Bug 破壞了第一層防禦，導致第二層被觸發。

## 修復方案

取消註解，恢復 flag 清除邏輯：

```diff
-        // BUG: Security check disabled - untrusted displays can now show system decorations
-        // Original code:
-        // if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
-        //     flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
-        // }
+        if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) == 0) {
+            flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
+        }
```

## 關鍵教訓

1. **不要註解掉安全檢查**：即使是「暫時」的，也可能被遺忘

2. **理解防禦深度**：移除一層防禦可能讓系統仍然「安全」，但會破壞功能和相容性

3. **註解也是程式碼**：Review 時要注意被註解的程式碼，特別是安全相關的

4. **測試的價值**：CTS 測試抓到了這個 bug，即使系統沒有被攻破，功能回退也是問題

## CTS 測試原理

`testUntrustedSysDecorVirtualDisplay` 的測試邏輯：

```java
@Test
public void testUntrustedSysDecorVirtualDisplay() {
    // 以普通 app 身份建立 VirtualDisplay，請求 system decorations
    VirtualDisplay display = mDisplayManager.createVirtualDisplay(
        "TestDisplay",
        WIDTH, HEIGHT, DENSITY,
        mSurface,
        VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS,
        null, null
    );
    
    // 預期：VirtualDisplay 正常建立，但 flag 被清除
    // 實際（有 bug）：拋出 SecurityException
    
    assertNotNull("VirtualDisplay should be created", display);
    
    int actualFlags = display.getDisplay().getFlags();
    assertEquals(
        "SHOULD_SHOW_SYSTEM_DECORATIONS should be stripped",
        0,
        actualFlags & Display.FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS
    );
}
```

## 難度評估：Hard

- **需要理解兩層防禦**：為什麼有兩個檢查？移除一個會怎樣？
- **誤導性強**：看到 Exception 可能以為「安全機制正常運作」
- **功能 vs 安全**：這是安全 bug 還是功能 bug？答案是兩者皆是
