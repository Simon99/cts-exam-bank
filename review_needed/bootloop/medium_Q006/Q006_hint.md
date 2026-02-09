# 提示

## 提示 1（輕微提示）
查看 `LogicalDisplayMapper.getDisplayIdsLocked()` 方法，特別是權限檢查的部分。

## 提示 2（中等提示）
`DisplayInfo.hasAccess(callingUid)` 返回：
- `true`: 呼叫者**有權限**訪問這個顯示器
- `false`: 呼叫者**沒有權限**訪問這個顯示器

思考：什麼樣的條件判斷會讓「有權限」的顯示器反而不被返回？

## 提示 3（強烈提示）
檢查條件判斷中的邏輯運算符是否正確。特別注意 `!`（否定）運算符的使用。

---

## 完整解答（面試後查看）

Bug 位於 `LogicalDisplayMapper.java` 第 310 行的 `getDisplayIdsLocked()` 方法：

```java
// Bug 版本（錯誤）
if (!info.hasAccess(callingUid)) {
    displayIds[n++] = mLogicalDisplays.keyAt(i);
}

// 正確版本
if (info.hasAccess(callingUid)) {
    displayIds[n++] = mLogicalDisplays.keyAt(i);
}
```

### 問題分析

這是一個**邏輯反轉錯誤**（Logic Inversion Bug）。

原本的意圖是：
- 如果呼叫者**有權限**訪問顯示器，就將其加入返回列表

但 bug 版本變成了：
- 如果呼叫者**沒有權限**訪問顯示器，才將其加入返回列表

結果就是 `getDisplays()` 返回的都是用戶**沒有**權限訪問的顯示器，
而真正有權限訪問的顯示器（如 DEFAULT_DISPLAY）反而不會被返回。

### 呼叫堆疊
```
DisplayManager.getDisplays()
  → DisplayManagerGlobal.getDisplayIds()
    → IDisplayManager.getDisplayIds() [Binder call]
      → DisplayManagerService.BinderService.getDisplayIds()
        → LogicalDisplayMapper.getDisplayIdsLocked()  ← Bug 在這裡
```

### 為什麼這是 Hard 難度
1. Bug 位於深層的服務層（LogicalDisplayMapper），不是直接的 API 層
2. 需要理解 DisplayManager 的多層架構
3. 需要理解 hasAccess() 的語義和權限模型
4. 邏輯反轉錯誤（單字符差異 `!`）容易被忽視
5. 需要追蹤多層呼叫才能定位問題
