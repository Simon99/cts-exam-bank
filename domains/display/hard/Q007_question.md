# CTS 題目：Display Event Listener 收不到 DISPLAY_CHANGED 事件

## 背景

某設備廠商報告了一個問題：使用 `DisplayManager.registerDisplayListener()` 的應用程式無法收到 `DISPLAY_CHANGED` 事件，儘管已正確訂閱了該事件類型。

例如，當 Virtual Display 的屬性（如大小）被修改時，已註冊的 listener 應該收到 `onDisplayChanged()` 回調，但實際上沒有收到任何通知。

## 失敗的 CTS 測試

```
android.display.cts.DisplayEventTest#testDisplayEvents
```

**測試模組**: `CtsDisplayTestCases`

## 症狀

1. 應用程式可以正常收到 `DISPLAY_ADDED` 和 `DISPLAY_REMOVED` 事件
2. 但 `DISPLAY_CHANGED` 事件完全不會被傳遞
3. 這導致無法即時追蹤 display 屬性的變化
4. 預設的 `registerDisplayListener()` 調用應該訂閱 ADDED、CHANGED、REMOVED 三種事件

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

## 任務

1. 找出導致 DISPLAY_CHANGED 事件無法傳遞的 bug
2. 解釋為什麼其他事件類型（ADDED、REMOVED）正常運作
3. 分析這個 bug 對事件訂閱機制的影響
4. 提供修復方案

## 提示

- 關注 `CallbackRecord` 類別中的 `shouldSendEvent()` 方法
- 思考 event type 與 event flag 的對應關係
- 檢查 switch-case 中各個 case 的 mask 檢查邏輯

## 評估標準

| 項目 | 配分 |
|------|------|
| 準確定位 bug 位置 | 25% |
| 正確解釋 bug 原因 | 25% |
| 分析事件過濾機制 | 25% |
| 提供有效修復方案 | 25% |

## 時間限制

35 分鐘
