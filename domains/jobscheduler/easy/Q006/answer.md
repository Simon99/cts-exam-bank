# Q006: 答案解析

## 問題根因
`DeviceIdlenessTracker.java` 中處理螢幕關閉時，在設置 idle handler 時錯誤地立即將 `mIdle` 設為 true。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/idle/DeviceIdlenessTracker.java`

## 錯誤代碼
```java
// Screen went off. Set up idle trigger if necessary.
if (mIdleTriggerHandler == null) {
    // ... set up handler ...
    mIdle = true;  // BUG: 不應該在設置 handler 時立即設置為 idle
}
```

## 正確代碼
```java
// Screen went off. Set up idle trigger if necessary.
if (mIdleTriggerHandler == null) {
    // ... set up handler ...
    // mIdle 應該在 idle timeout 之後才設為 true，不是立即設置
}
```

## 修復步驟
1. 打開 `DeviceIdlenessTracker.java`
2. 找到處理螢幕關閉的程式碼區塊
3. 移除在 handler 設置區塊中直接將 `mIdle = true` 的錯誤程式碼

## 追蹤路徑
1. CTS log 顯示：`IdleConstraintTest#testDeviceChangeIdleActiveState` 失敗
2. 錯誤訊息：作業在螢幕關閉後立即執行，但應該等待 idle timeout
3. 搜尋 `DeviceIdlenessTracker` → 找到 `mIdle` 狀態管理
4. 發現 `mIdle = true` 被放在了錯誤的位置

## 測試驗證
```bash
atest android.jobscheduler.cts.IdleConstraintTest#testDeviceChangeIdleActiveState
```

## 相關知識點
- 設備閒置狀態的判定流程需要經過 timeout
- 螢幕關閉 ≠ 立即閒置
- IdleController 追蹤設備閒置狀態的機制
