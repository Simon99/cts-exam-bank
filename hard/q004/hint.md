# 提示

## 第一層提示

查看 `DisplayManagerService.java` 中的 `createVirtualDisplayInternal()` 方法。關注處理 VirtualDisplay flags 的邏輯，特別是 `VIRTUAL_DISPLAY_FLAG_TRUSTED` 和 `VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS` 之間的關係。

## 第二層提示

系統裝飾（status bar、navigation bar 等）可能包含敏感資訊。如果允許任何應用創建一個帶有系統裝飾的 VirtualDisplay，惡意應用可以通過讀取 display surface 來竊取這些資訊。

因此，只有 **受信任的 (TRUSTED)** VirtualDisplay 才應該被允許顯示系統裝飾。

## 第三層提示

查看這段代碼：

```java
if ((flags & VIRTUAL_DISPLAY_FLAG_TRUSTED) != 0) {
    flags &= ~VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS;
}
```

這段代碼說的是：「如果 display 是 TRUSTED，則清除 SHOULD_SHOW_SYSTEM_DECORATIONS flag」。

但安全邏輯應該是相反的：「如果 display **不是** TRUSTED，則清除 SHOULD_SHOW_SYSTEM_DECORATIONS flag」。

檢查條件運算符：`!= 0` 應該是 `== 0`。

## 答案方向

這是一個**條件邏輯反轉錯誤**（inverted condition bug）。錯誤地將 `== 0` 寫成 `!= 0`，導致安全檢查的邏輯完全相反：

- **錯誤行為**：信任的 display 被剝奪系統裝飾，不信任的 display 反而保留了系統裝飾
- **正確行為**：只有信任的 display 才能保留系統裝飾，不信任的 display 必須清除這個 flag
