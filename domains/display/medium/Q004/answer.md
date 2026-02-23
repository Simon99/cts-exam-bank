# 答案與解析

## 正確答案：B

## Bug 位置

**檔案**：`frameworks/base/core/java/android/view/Display.java`

**函數**：`hasAccess(int uid, int flags, int ownerUid, int displayId)`

**行號**：1827

## 錯誤程式碼

```java
public static boolean hasAccess(int uid, int flags, int ownerUid, int displayId) {
    return (flags & Display.FLAG_PRIVATE) != 0  // Bug: 應該是 == 0
            || uid == ownerUid
            || uid == Process.SYSTEM_UID
            || uid == 0
            || DisplayManagerGlobal.getInstance().isUidPresentOnDisplay(uid, displayId);
}
```

## 正確程式碼

```java
public static boolean hasAccess(int uid, int flags, int ownerUid, int displayId) {
    return (flags & Display.FLAG_PRIVATE) == 0  // 正確：非 private display 允許所有人存取
            || uid == ownerUid
            || uid == Process.SYSTEM_UID
            || uid == 0
            || DisplayManagerGlobal.getInstance().isUidPresentOnDisplay(uid, displayId);
}
```

## 修復 Patch

```diff
-        return (flags & Display.FLAG_PRIVATE) != 0
+        return (flags & Display.FLAG_PRIVATE) == 0
```

## 根本原因分析

`hasAccess()` 方法的邏輯是判斷某個 UID 是否有權限存取特定 display。存取權限的判斷條件應該是：

1. **非 private display** → 任何人都可以存取（`FLAG_PRIVATE == 0` 的 display）
2. **Display owner** → owner 可以存取自己的 display
3. **System UID** → 系統進程可以存取任何 display
4. **Root UID** → root 可以存取任何 display
5. **UID present on display** → 已經在該 display 上有 activity 的 UID

Bug 將第一個條件的 `== 0` 錯誤改成 `!= 0`，導致邏輯完全反轉：

- **原本（正確）**：`(flags & FLAG_PRIVATE) == 0` → 如果 display 沒有 FLAG_PRIVATE（即是 public），允許存取
- **錯誤**：`(flags & FLAG_PRIVATE) != 0` → 如果 display 有 FLAG_PRIVATE（即是 private），才允許存取

這導致 public display（如 overlay display、presentation display）反而無法被普通應用存取，而只有 private display 才能被存取，完全顛倒了設計意圖。

## 影響範圍

- `DisplayManager.getDisplays()` 無法回傳 public display
- 多螢幕應用程式（如 Presentation API）無法發現可用的 display
- 所有依賴 display 存取權限的功能都會異常

## 選項分析

**A. 將 `uid == ownerUid` 改為 `uid != ownerUid`**
- 錯誤。這會讓 owner 無法存取自己的 display，反而讓非 owner 可以存取。

**B. 將 `(flags & Display.FLAG_PRIVATE) != 0` 改為 `(flags & Display.FLAG_PRIVATE) == 0`**
- 正確。這修復了 public display 存取權限的判斷邏輯。

**C. 將 `uid == Process.SYSTEM_UID` 改為 `uid >= Process.SYSTEM_UID`**
- 錯誤。SYSTEM_UID 是 1000，這個改動會讓所有 UID >= 1000 的進程都有 system 權限，產生嚴重安全漏洞。

**D. 移除 `isUidPresentOnDisplay` 的檢查**
- 錯誤。這會移除一個合法的存取權限判斷條件，降低安全性。

## 測試驗證

修復後，`testGetDisplays` 測試會：
1. 取得所有可見的 display（包含 default 和 overlay display）
2. 確認 secondary display 存在
3. 測試通過

## 學習要點

1. **Bitwise 操作注意方向** — `== 0` 和 `!= 0` 的差異在於「沒有設定該 flag」vs「有設定該 flag」
2. **Display 存取權限模型** — Android 使用 FLAG_PRIVATE 來區分 public 和 private display
3. **條件反轉是常見 bug** — 開發者容易在複雜條件中混淆 `==` 和 `!=`
