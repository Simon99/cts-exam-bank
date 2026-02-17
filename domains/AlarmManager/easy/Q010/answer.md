# Q010 Answer: Alarm Matches Wrong PendingIntent

## 正確答案
**A. `matches()` 使用 `==` 比較 PendingIntent 而非 `filterEquals()`**

## 問題根因
在 `Alarm.java` 的 `matches()` 方法中，
比較 PendingIntent 應該使用 `filterEquals()` 方法（比較 Intent 的核心屬性），
但 bug 使用了 `==` 運算符，只比較物件參考。
由於每次獲取 PendingIntent 可能是不同物件，即使內容相同也會返回 false。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/Alarm.java`

## 修復方式
```java
// 錯誤的代碼
public boolean matches(PendingIntent pi) {
    return operation == pi;  // BUG: 應該用 filterEquals()
}

// 正確的代碼
public boolean matches(PendingIntent pi) {
    return operation != null && operation.filterEquals(pi);
}
```

## 相關知識
- `PendingIntent.filterEquals()` 比較 action, data, type, class, categories
- `==` 只比較物件參考，不同物件即使內容相同也返回 false
- matches() 用於取消鬧鐘和去重複

## 難度說明
**Easy** - 從 fail log 可以看出 matches() 返回錯誤，理解 PendingIntent 比較語意即可發現問題。
