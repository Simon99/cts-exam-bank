# Q008 Answer: Alarm isExact Check Wrong

## 正確答案
**A. `isExact()` 判斷條件使用 `windowLength > 0` 而非 `windowLength == 0`**

## 問題根因
在 `Alarm.java` 的 `isExact()` 方法中，
判斷鬧鐘是否為精確鬧鐘應該檢查 `windowLength == 0`，
但 bug 將條件寫成 `windowLength > 0`，邏輯完全相反。
這導致只有 inexact 鬧鐘被當成 exact，而真正的 exact 鬧鐘被當成 inexact。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/Alarm.java`

## 修復方式
```java
// 錯誤的代碼
public boolean isExact() {
    return windowLength > 0;  // BUG: 應該是 == 0
}

// 正確的代碼
public boolean isExact() {
    return windowLength == 0;
}
```

## 相關知識
- `windowLength == 0` 表示 WINDOW_EXACT，需要精確觸發
- `windowLength > 0` 表示有彈性窗口，可以 batch
- isExact() 影響鬧鐘的排程和電池優化決策

## 難度說明
**Easy** - 從 fail log 可以看出 isExact() 返回值錯誤，檢查方法實作即可發現邏輯問題。
