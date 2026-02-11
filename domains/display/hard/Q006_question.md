# CTS 題目：Display Event Delivery Bug

**難度**: Hard  
**預計時間**: 35 分鐘  
**CTS 測試**: `android.hardware.display.cts.DisplayEventTest#testDisplayEvents`

---

## 問題描述

在 Android 系統中，`DisplayManagerService` 負責管理顯示設備並向已註冊的 callbacks 發送顯示事件通知。當應用程式處於 cached 狀態時，系統會將事件暫存在 `PendingCallback` 中，待應用變為活躍狀態時再批量發送。

一位工程師在審查代碼時，注意到事件去重邏輯可能存在效能問題，於是進行了「優化」。修改後，CTS 測試 `DisplayEventTest#testDisplayEvents` 開始間歇性失敗。

測試失敗的症狀：
- 當系統有多個 display 時，部分 display 的事件通知丟失
- 事件丟失只發生在 cached apps 上
- 單一 display 的場景下測試正常通過

---

## 你的任務

1. 分析以下源碼檔案，找出導致 CTS 測試失敗的 bug
2. 說明 bug 的根本原因和觸發條件
3. 提供修復方案

**源碼位置**: 
```
frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
```

**重點關注區域**: `PendingCallback` 類別，特別是 `addDisplayEvent()` 方法（約 3666-3677 行）

---

## 相關背景知識

### Display Event 類型
- `EVENT_DISPLAY_ADDED` - 新增顯示設備
- `EVENT_DISPLAY_CHANGED` - 顯示設備屬性變更
- `EVENT_DISPLAY_REMOVED` - 移除顯示設備
- `EVENT_DISPLAY_BRIGHTNESS_CHANGED` - 亮度變更
- `EVENT_DISPLAY_HDR_SDR_RATIO_CHANGED` - HDR/SDR 比例變更

### Cached App 機制
當應用進入 cached 狀態（低優先級後台），系統會延遲事件傳遞以節省資源。事件會暫存在 `PendingCallback` 中，待應用變為活躍時再發送。

### 事件去重邏輯
為避免向同一應用發送重複事件，`addDisplayEvent()` 會檢查新事件是否與最後一個事件相同。

---

## 提示

1. 思考：什麼情況下「相同的事件類型」實際上是「不同的事件」？
2. 考慮多 display 場景：手機連接外接螢幕、投影等
3. 分析去重邏輯的判斷條件是否完整

---

## 答題格式

請按以下格式提交答案：

```
## Bug 位置
[指出具體的程式碼位置和有問題的邏輯]

## 根本原因
[解釋為什麼這段代碼會導致測試失敗]

## 觸發條件
[描述什麼情況下會觸發這個 bug]

## 修復方案
[提供具體的修復代碼或思路]
```
