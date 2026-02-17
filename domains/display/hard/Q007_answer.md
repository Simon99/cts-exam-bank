# 答案：Display Event Listener 收不到 DISPLAY_CHANGED 事件

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**類別**: `CallbackRecord` (內部類別)

**方法**: `shouldSendEvent()`

## Bug 描述

在 `shouldSendEvent()` 方法中，`EVENT_DISPLAY_CHANGED` 事件類型錯誤地檢查了 `EVENT_FLAG_DISPLAY_BRIGHTNESS` flag，而不是正確的 `EVENT_FLAG_DISPLAY_CHANGED` flag。

### 錯誤程式碼

```java
private boolean shouldSendEvent(@DisplayEvent int event) {
    final long mask = mEventsMask.get();
    switch (event) {
        case DisplayManagerGlobal.EVENT_DISPLAY_ADDED:
            return (mask & DisplayManager.EVENT_FLAG_DISPLAY_ADDED) != 0;
        case DisplayManagerGlobal.EVENT_DISPLAY_CHANGED:
            // Bug: 檢查了錯誤的 flag
            return (mask & DisplayManager.EVENT_FLAG_DISPLAY_BRIGHTNESS) != 0;
        // ...
    }
}
```

### 正確程式碼

```java
case DisplayManagerGlobal.EVENT_DISPLAY_CHANGED:
    return (mask & DisplayManager.EVENT_FLAG_DISPLAY_CHANGED) != 0;
```

## 根本原因分析

### 1. 事件訂閱機制

當應用程式調用 `registerDisplayListener()` 時，預設會訂閱三種事件：
- `EVENT_FLAG_DISPLAY_ADDED`
- `EVENT_FLAG_DISPLAY_CHANGED`
- `EVENT_FLAG_DISPLAY_REMOVED`

注意：**不包含** `EVENT_FLAG_DISPLAY_BRIGHTNESS`。

### 2. 事件過濾邏輯

`shouldSendEvent()` 方法在發送事件前檢查 listener 是否訂閱了該事件類型。由於 bug 導致 DISPLAY_CHANGED 事件檢查了 BRIGHTNESS flag，而預設訂閱不包含 BRIGHTNESS，所以條件永遠為 false。

### 3. 影響範圍

- `DISPLAY_ADDED` 事件：正常運作（正確檢查 ADDED flag）
- `DISPLAY_CHANGED` 事件：**永遠不會被傳遞**（錯誤檢查 BRIGHTNESS flag）
- `DISPLAY_REMOVED` 事件：正常運作（正確檢查 REMOVED flag）

## 修復方案

修正 `shouldSendEvent()` 中的 flag 檢查：

```java
case DisplayManagerGlobal.EVENT_DISPLAY_CHANGED:
    return (mask & DisplayManager.EVENT_FLAG_DISPLAY_CHANGED) != 0;
```

## CTS 測試失敗分析

`testDisplayEvents` 測試會：
1. 建立 Virtual Display
2. 修改 display 屬性（觸發 DISPLAY_CHANGED）
3. 等待並驗證收到 DISPLAY_CHANGED 事件

由於 bug，步驟 3 的等待會超時，因為事件永遠不會被傳遞。

## 教訓

1. **複製貼上的風險**：switch-case 中的 copy-paste 容易引入這類 bug
2. **事件 flag 的對應關係**：必須確保 event type 與 event flag 正確對應
3. **單元測試的重要性**：應該有測試覆蓋每個事件類型的過濾邏輯
