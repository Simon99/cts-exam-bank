# Q007 Answer: legacyExactLength SDK Check Wrong

## 正確答案
**A. `legacyExactLength()` 的 SDK 版本比較使用 `>=` 而非 `<`**

## 問題根因
在 `AlarmManager.java` 的 `legacyExactLength()` 方法中，
判斷是否需要精確行為時應該用 `targetSdkVersion < KITKAT`，
但 bug 將條件寫成 `targetSdkVersion >= KITKAT`，導致邏輯完全相反：
舊版 app 被當成新版，新版 app 反而有精確行為。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 413-415)

## 修復方式
```java
// 錯誤的代碼
private long legacyExactLength(int type) {
    if (mContext.getApplicationInfo().targetSdkVersion >= Build.VERSION_CODES.KITKAT) {
        return WINDOW_EXACT;
    }
    return WINDOW_HEURISTIC;
}

// 正確的代碼
private long legacyExactLength(int type) {
    if (mContext.getApplicationInfo().targetSdkVersion < Build.VERSION_CODES.KITKAT) {
        return WINDOW_EXACT;
    }
    return WINDOW_HEURISTIC;
}
```

## 相關知識
- KITKAT (API 19) 引入了 alarm batching 節省電力
- targetSdkVersion < KITKAT 的 app 保持舊行為（精確）
- `WINDOW_EXACT` = 0，`WINDOW_HEURISTIC` = 非零 window

## 難度說明
**Easy** - 從 fail log 可以看出舊版 app 行為異常，檢查 legacyExactLength() 邏輯即可發現。
