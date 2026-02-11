# CTS 題目：Display Event Listener Mask 狀態管理問題

## 背景

某設備廠商報告了一個奇怪的問題：使用 `DisplayManager.registerDisplayListener()` 的應用程式在嘗試更新事件訂閱 mask 後，仍然會收到不應該收到的事件。

例如，應用程式最初訂閱了 `EVENT_FLAG_DISPLAY_ADDED | EVENT_FLAG_DISPLAY_CHANGED`，後來想只監聽 `EVENT_FLAG_DISPLAY_ADDED`（通過重新註冊），但仍然會收到 `DISPLAY_CHANGED` 事件。

## 失敗的 CTS 測試

```
android.hardware.display.cts.DisplayEventTest#testDisplayEvents
```

**測試模組**: `CtsDisplayTestCases`

## 症狀

1. 應用程式無法通過更新 eventsMask 來取消對特定事件類型的訂閱
2. 事件 mask 只會增加，永遠不會減少
3. 這會導致應用程式收到大量不需要的事件，影響效能
4. 在某些 race condition 情況下，可能導致測試斷言失敗

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

## 任務

1. 找出導致事件 mask 無法正確更新的 bug
2. 解釋為什麼這個 bug 會導致狀態管理問題
3. 分析這個 bug 對多執行緒環境的影響
4. 提供修復方案

## 提示

- 關注 `CallbackRecord` 類別中與 `mEventsMask` 相關的操作
- 思考 `AtomicLong` 的各種操作方法的語義差異
- 考慮 `set()` vs `getAndAccumulate()` 的行為差異

## 評估標準

| 項目 | 配分 |
|------|------|
| 準確定位 bug 位置 | 25% |
| 正確解釋 bug 原因 | 25% |
| 分析狀態管理問題 | 25% |
| 提供有效修復方案 | 25% |

## 時間限制

35 分鐘
