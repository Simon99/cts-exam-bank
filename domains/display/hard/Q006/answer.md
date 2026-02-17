# Q006 答案：Display Event Delivery Bug

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**位置**: `PendingCallback.addDisplayEvent()` 方法，約第 3669 行

**問題代碼**:
```java
public void addDisplayEvent(int displayId, int event) {
    // Ignore redundant events. Further optimization is possible by merging adjacent events.
    Pair<Integer, Integer> last = mDisplayEvents.get(mDisplayEvents.size() - 1);
    // BUG: 條件判斷缺少 displayId 檢查
    if (last.second == event) {  // 錯誤：只檢查 event 類型
        Slog.d(TAG,
                "Ignore redundant display event " + displayId + "/" + event + " to "
                        + mCallbackRecord.mUid + "/" + mCallbackRecord.mPid);
        return;
    }
    mDisplayEvents.add(new Pair<>(displayId, event));
}
```

---

## 根本原因

原始的去重邏輯應該是：
```java
if (last.first == displayId && last.second == event)
```

這個條件確保只有當 **同一個 displayId** 且 **同一個 event 類型** 時才視為重複。

但「優化」後的代碼變成：
```java
if (last.second == event)
```

這個條件 **只檢查 event 類型**，忽略了 displayId。這導致：

1. Display A 觸發 `EVENT_DISPLAY_CHANGED`，被加入 pending list
2. Display B 觸發 `EVENT_DISPLAY_CHANGED`，因為 event 類型相同，被錯誤地視為「重複」而丟棄
3. 應用只收到 Display A 的事件，Display B 的事件丟失

這是典型的 **COND 類型錯誤**：條件判斷過於寬鬆，將不同的事件誤判為相同。

---

## 觸發條件

1. **多 Display 環境**：系統連接了多個顯示設備（如手機 + 外接螢幕、投影）
2. **Cached App 狀態**：接收事件的應用處於 cached 狀態（低優先級後台）
3. **相同類型事件快速發生**：多個 display 在短時間內觸發相同類型的事件
4. **事件順序**：後發生的事件緊接在前一個相同類型事件之後

**典型場景**：
- 用戶連接 HDMI 外接螢幕，兩個 display 同時觸發 `EVENT_DISPLAY_CHANGED`
- 調整亮度時，多個 display 同時觸發 `EVENT_DISPLAY_BRIGHTNESS_CHANGED`
- 外接多螢幕工作站環境

---

## 修復方案

將條件恢復為完整的檢查：

```java
public void addDisplayEvent(int displayId, int event) {
    // Ignore redundant events. Further optimization is possible by merging adjacent events.
    Pair<Integer, Integer> last = mDisplayEvents.get(mDisplayEvents.size() - 1);
    // 正確：必須同時檢查 displayId 和 event 類型
    if (last.first == displayId && last.second == event) {
        Slog.d(TAG,
                "Ignore redundant display event " + displayId + "/" + event + " to "
                        + mCallbackRecord.mUid + "/" + mCallbackRecord.mPid);
        return;
    }
    mDisplayEvents.add(new Pair<>(displayId, event));
}
```

**修復 Patch**:
```diff
-            // Optimization: skip duplicate event types across all displays
-            if (last.second == event) {
+            if (last.first == displayId && last.second == event) {
```

---

## 評分標準

| 項目 | 分數 | 說明 |
|------|------|------|
| 定位 Bug 位置 | 25% | 正確指出 `addDisplayEvent()` 的條件判斷問題 |
| 解釋根本原因 | 30% | 說明為何缺少 displayId 檢查會導致事件丟失 |
| 描述觸發條件 | 20% | 識別多 display + cached app + 相同事件類型的組合 |
| 提供修復方案 | 25% | 給出正確的條件修復或等效方案 |

---

## 延伸討論

### 為什麼這個 bug 難以發現？

1. **單 display 環境下完全正常**：大多數開發和測試都在單一螢幕環境
2. **需要特定的 app 狀態**：只影響 cached apps，活躍 apps 不受影響
3. **間歇性**：需要多個事件快速連續發生才會觸發
4. **「優化」的假象**：代碼修改看起來像合理的效能改進

### 類似的 Bug 模式

這類 bug 屬於「過度簡化條件」模式，常見於：
- 快取鍵值生成時忽略部分參數
- 事件去重時只比較部分欄位
- 狀態機轉換時缺少狀態檢查

### 預防措施

1. 代碼審查時特別關注條件判斷的完整性
2. 測試覆蓋多元件/多實例場景
3. 變更「優化」代碼時需要完整的回歸測試
