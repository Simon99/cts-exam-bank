# Q007: 答案解析

## 問題根因
`IdleController` 或 `DeviceIdlenessTracker` 在自動投影狀態變化時沒有正確更新閒置狀態。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/IdleController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/idle/DeviceIdlenessTracker.java`

## 錯誤代碼
```java
// 在 DeviceIdlenessTracker 中
public void setAutomotiveProjectionActive(boolean active) {
    mProjectionActive = active;
    if (!active) {
        // BUG: 關閉投影時沒有重新評估閒置狀態
        // 缺少檢查其他條件並可能設為閒置的邏輯
    }
    // 應該調用 reportIdleChange()
}
```

## 正確代碼
```java
public void setAutomotiveProjectionActive(boolean active) {
    mProjectionActive = active;
    if (!active && !mScreenOn && !mDockActive) {
        // 如果沒有其他阻止閒置的因素，設備應該進入閒置
        mIdle = true;
    } else if (active) {
        mIdle = false;
    }
    reportIdleChange();  // 通知狀態變化
}
```

## 調試步驟
1. 添加 log 追蹤投影和閒置狀態：
```java
Slog.d(TAG, "setAutomotiveProjectionActive: active=" + active 
        + " mScreenOn=" + mScreenOn + " mIdle=" + mIdle);
```

2. 執行測試查看狀態變化

## 測試驗證
```bash
atest android.jobscheduler.cts.IdleConstraintTest#testAutomotiveProjectionPreventsIdle
```

## 相關知識點
- 自動投影讓設備認為用戶正在交互（例如 Android Auto）
- 閒置狀態取決於多個因素：螢幕狀態、投影狀態、dock 狀態
- 狀態變化後需要重新評估整體閒置狀態
