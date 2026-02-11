# Q001 Answer: MotionEvent getAction() 回傳錯誤

## 正確答案
**A) `getAction()` 中的 `return mAction;` 被錯誤地寫成 `return ACTION_UP;`**

## 問題根因
在 `MotionEvent.java` 的 `getAction()` 函數中，回傳語句被硬編碼為 `ACTION_UP`，
而非回傳實際儲存的動作碼 `mAction`。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getAction() {
    return ACTION_UP;  // BUG: 硬編碼了 ACTION_UP
}

// 正確的代碼
public final int getAction() {
    return mAction;
}
```

## 為什麼其他選項不對

**B)** `getAction()` 不需要做位元遮罩運算，那是 `getActionMasked()` 的工作。
`getAction()` 應直接回傳原始的 action 值（包含 pointer index）。

**C)** 位元反轉會把 0 變成 -1（全 1），不會產生 ACTION_UP (1)。

**D)** 常數值是正確的（ACTION_DOWN=0, ACTION_UP=1），問題在於回傳邏輯。

## 相關知識
- MotionEvent 動作碼的設計：低 8 位是動作類型，高位包含 pointer index
- `getAction()` vs `getActionMasked()` 的區別
- Android 輸入事件處理流程

## 難度說明
**Easy** - 從 fail log 可以直接看出動作碼錯誤，檢查 getAction() 函數即可定位。
