# CTS 失敗分析題 - DIS-H009

## 題目資訊
- **難度**: Hard
- **預計時間**: 40 分鐘
- **領域**: Display Manager / Refresh Rate Switching

---

## 問題描述

一位開發者在修改 `DisplayManagerService.java` 的 refresh rate switching 邏輯後，CTS 測試開始失敗。

### 失敗的 CTS 測試

```
Module: CtsDisplayTestCases
Test: android.display.cts.DisplayTest#testModeSwitchOnPrimaryDisplay
```

### 錯誤訊息

```
junit.framework.AssertionFailedError: Refresh rate switching type mismatch
Expected: SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS (2)
Actual: SWITCHING_TYPE_WITHIN_GROUPS (1)

    at android.display.cts.DisplayTest.testModeSwitchOnPrimaryDisplay(DisplayTest.java:342)
    at java.lang.reflect.Method.invoke(Native Method)
    at android.test.InstrumentationTestCase.runMethod(InstrumentationTestCase.java:214)
```

### 測試行為說明

`testModeSwitchOnPrimaryDisplay` 測試會：
1. 設置 refresh rate switching type 為 `SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS` (2)
2. 讀取當前的 switching type 並驗證是否與設置值相符
3. 驗證 display mode 切換行為是否正確

---

## 相關程式碼位置

請分析以下檔案中的 bug：
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`
  - `setRefreshRateSwitchingTypeInternal()` 方法（約第 2500 行）
  - `getRefreshRateSwitchingTypeInternal()` 方法（約第 2505 行）

### 背景知識

**Refresh Rate Switching Types:**
```java
SWITCHING_TYPE_NONE = 0;                      // 不切換
SWITCHING_TYPE_WITHIN_GROUPS = 1;             // 同組內切換
SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS = 2;  // 跨組切換
SWITCHING_TYPE_RENDER_FRAME_RATE_ONLY = 3;    // 僅渲染幀率切換
```

---

## 作答要求

1. **找出 Bug（20 分）**
   - 指出導致 CTS 失敗的具體問題
   - 說明這是什麼類型的 bug（狀態不一致 / 邊界錯誤 / 邏輯錯誤等）

2. **分析根因（30 分）**
   - 解釋為什麼這個 bug 會導致測試失敗
   - 追蹤 set/get 之間的狀態不一致鏈
   - 說明哪些 switching type 值會受影響

3. **提供修復方案（30 分）**
   - 提供正確的程式碼修復
   - 說明修復的原理

4. **深入分析（20 分）**
   - 這個 bug 在實際設備上會造成什麼用戶體驗問題？
   - 如果 SWITCHING_TYPE_RENDER_FRAME_RATE_ONLY (3) 被使用，會發生什麼？
   - 如何透過單元測試或整合測試預防這類 bug？

---

## 評分標準

| 項目 | 優秀 | 良好 | 需改進 |
|------|------|------|--------|
| Bug 識別 | 準確指出跨函數狀態不一致問題 | 找到部分問題 | 未能識別核心問題 |
| 根因分析 | 完整追蹤狀態流並解釋影響 | 部分正確分析 | 分析不完整 |
| 修復方案 | 方案正確且考慮邊界情況 | 方案可行但不完整 | 方案有缺陷 |
| 深入理解 | 展現對系統級影響的理解 | 理解部分影響 | 缺乏系統視角 |

---

## 提示

- 這是一個涉及**多個函數**的狀態一致性問題
- 注意 `set` 和 `get` 之間的值可能不匹配
- 仔細檢查邊界條件的處理邏輯
- 考慮所有四種 SWITCHING_TYPE 值的行為
