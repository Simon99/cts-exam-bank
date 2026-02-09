# Q009 提示

## 提示等級 1（方向性）

這是一個跨檔案的狀態同步問題。關注 DisplayInfo 物件在不同組件間如何傳遞和比較。

## 提示等級 2（範圍縮小）

問題在於 DisplayManagerGlobal 如何決定是否觸發 `onDisplayChanged` 回調。

關鍵邏輯在 `DisplayListenerDelegate.handleDisplayEventInner()` 中：

```java
if (info != null && (forceUpdate || !info.equals(mDisplayInfo))) {
    mDisplayInfo.copyFrom(info);
    mListener.onDisplayChanged(displayId);
}
```

這裡的 `equals()` 方法決定了一切。

## 提示等級 3（具體方向）

檢查 `DisplayInfo.equals()` 方法。問問自己：

1. `equals()` 比較了哪些欄位？
2. `copyFrom()` 複製了哪些欄位？
3. 這兩個方法的欄位列表是否完全一致？

特別關注 `rotation` 欄位。

## 提示等級 4（關鍵行）

比較 `DisplayInfo.java` 中的這兩個方法：

**equals() 方法（約第 407-459 行）：**
```java
public boolean equals(DisplayInfo other) {
    return other != null
            && layerStack == other.layerStack
            // ... 一長串比較
            && rotation == other.rotation  // <-- 這一行存在嗎？
            // ...
}
```

**copyFrom() 方法（約第 466-517 行）：**
```java
public void copyFrom(DisplayInfo other) {
    // ... 
    rotation = other.rotation;  // 這一行是存在的
    // ...
}
```

如果 `equals()` 漏掉了 `rotation` 的比較，會發生什麼？

## 答案

Bug 在 `DisplayInfo.equals()` 方法中遺漏了 `rotation == other.rotation` 的比較。

**影響鏈：**
1. 設備旋轉 → WindowManager 更新 rotation
2. `LogicalDisplay.setDisplayInfoOverrideFromWindowManagerLocked()` 接收更新
3. DisplayManagerService 發送 `EVENT_DISPLAY_CHANGED`
4. `DisplayManagerGlobal.handleDisplayEvent()` 獲取新 DisplayInfo
5. `info.equals(mDisplayInfo)` 錯誤返回 `true`（因為沒比較 rotation）
6. `onDisplayChanged` 回調不被觸發

**修復：** 在 `equals()` 中添加 `&& rotation == other.rotation`

**這是一個典型的跨檔案一致性 bug：**
- `DisplayInfo.java` 的 `copyFrom()` 正確複製 rotation
- 但 `equals()` 漏掉了比較
- `DisplayManagerGlobal.java` 依賴 `equals()` 做決策
- `LogicalDisplay.java` 提供了正確的 rotation 更新
