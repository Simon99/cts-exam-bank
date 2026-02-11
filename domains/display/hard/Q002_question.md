# CTS 題目：DIS-H002

## 失敗的 CTS 測試

```
android.display.cts.DisplayTest#testMode
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Display supported modes count mismatch.
Expected: 4
Actual: 3
Missing mode: Mode{id=4, resolution=1080x2340, refreshRate=120.0}

    at android.display.cts.DisplayTest.testMode(DisplayTest.java:287)
```

## 問題背景

工程師收到用戶反饋：「我的手機明明支援 120Hz，但有時候設定裡面只能看到 60Hz 和 90Hz 兩個選項，重新開機後又正常了。」

QA 團隊發現這個問題與螢幕狀態更新有關，當系統認為顯示配置需要重新計算時，部分顯示模式會「消失」。

## 技術線索

1. **觸發條件**：只在 `LogicalDisplay.mDirty` 標誌為 true 時發生
2. **影響範圍**：支援多種顯示模式的設備（2個以上模式）
3. **現象**：`Display.getSupportedModes()` 返回的模式數量比實際少 1 個
4. **復現條件**：
   - 顯示群組變更後立即查詢支援模式
   - 熱拔插外接顯示器時
   - 刷新率限制設定變更後

## 相關原始碼位置

- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`
  - 重點關注 `updateLocked()` 方法（約 380-530 行）
  - 特別注意 `supportedModes` 的處理邏輯

## 提示

1. **狀態標誌影響**：`mDirty` 標誌如何影響模式列表的複製？
2. **陣列複製邏輯**：`Arrays.copyOf()` 的第二個參數（長度）是否正確？
3. **條件邊界**：為什麼只有多模式設備會受影響？

## 你的任務

1. 找出導致 `supportedModes` 陣列長度不正確的程式碼
2. 分析為什麼這個 bug 與 `mDirty` 狀態相關
3. 提供修復方案

---
*難度：Hard | 預估時間：35 分鐘 | 類型：STATE, CALC*
