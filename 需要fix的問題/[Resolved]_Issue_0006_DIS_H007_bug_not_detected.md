# Issue 0006: DIS-H007 Bug 未被偵測

## 基本資訊
- **題目 ID**: DIS-H007 (display/hard/Q007)
- **發現日期**: 2026-02-12
- **嚴重程度**: Medium（題目無效，需重新設計）

## 問題描述

Bug patch 套用後，CTS 測試仍然 PASS（8/8），bug 沒有被偵測到。

## Bug Patch 內容

```java
// 原始
mEventsMask.set(eventsMask);

// Bug（改用累加器，mask 只會增加不會減少）
mEventsMask.getAndAccumulate(eventsMask, (prev, update) -> prev | update);
```

## CTS 測試結果

```
atest android.display.cts.DisplayEventTest#testDisplayEvents

[1/8] #testDisplayEvents[#0: 1 false]: PASSED
[2/8] #testDisplayEvents[#1: 2 false]: PASSED
[3/8] #testDisplayEvents[#2: 3 false]: PASSED
[4/8] #testDisplayEvents[#3: 10 false]: PASSED
[5/8] #testDisplayEvents[#4: 1 true]: PASSED
[6/8] #testDisplayEvents[#5: 2 true]: PASSED
[7/8] #testDisplayEvents[#6: 3 true]: PASSED
[8/8] #testDisplayEvents[#7: 10 true]: PASSED

All tests passed!
```

## 問題分析

Bug 設計的問題：
- `getAndAccumulate` 會讓 eventsMask 只累加不減少
- 但 `testDisplayEvents` 測試沒有驗證「取消訂閱後不再收到事件」的邏輯
- 測試只驗證「訂閱後能收到事件」，所以 bug 不會被偵測

## 建議修復方案

### 方案 A：換不同的 CTS 測試
找一個會驗證「取消訂閱」或「mask 減少」邏輯的測試

### 方案 B：重新設計 Bug
選擇一個能被 `testDisplayEvents` 偵測的 bug 類型：
- 讓事件回調延遲或丟失
- 讓事件類型錯誤
- 讓回調執行緒錯誤

## 相關檔案
- Bug Patch: `domains/display/hard/Q007_bug.patch`
- 修改檔案: `DisplayManagerService.java`

## 狀態
- [ ] 待修復
