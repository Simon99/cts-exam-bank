# Q009 提示

## 提示 1 - 入門
`DisplayManagerGlobal.handleDisplayEventInner()` 中有一個條件判斷：
```java
if (info != null && (forceUpdate || !info.equals(mDisplayInfo))) {
    mListener.onDisplayChanged(displayId);
}
```
這個 `forceUpdate` 參數是關鍵。

---

## 提示 2 - 進階
有兩條主要的事件路徑：
1. **WindowManager 路徑**: `handleDisplayChangeFromWindowManager()` 使用 `forceUpdate=true`
2. **DisplayManagerService 路徑**: `DisplayManagerCallback.onDisplayEvent()` 使用 `forceUpdate=false`

setUserPreferredDisplayMode 使用哪條路徑？

---

## 提示 3 - 關鍵
當 `forceUpdate=false` 時，是否觸發 `onDisplayChanged` 完全依賴於 `equals()` 方法。

檢查 `DisplayInfo.equals()` 方法，看看它比較了哪些欄位。

`setUserPreferredDisplayMode` 會改變哪個欄位？這個欄位有在 `equals()` 中被比較嗎？

---

## 提示 4 - 答案方向
找到 `DisplayInfo.equals()` 方法（大約在第 420-450 行）。

需要新增或修復的比較是：
```java
&& defaultModeId == other.defaultModeId
```

如果這行遺漏或被移除，當 defaultModeId 改變時，equals() 仍然返回 true，導致 onDisplayChanged 不被調用。
