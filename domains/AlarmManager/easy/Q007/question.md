# Q007: legacyExactLength SDK Check Wrong

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testLegacyExactBehavior`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm on legacy app did not respect exact timing
expected: alarm to fire within legacy exact window
actual: alarm fired with inexact batching delay

at android.alarmmanager.cts.BasicApiTests.testLegacyExactBehavior(BasicApiTests.java:198)
```

## 現象描述
針對 targetSdkVersion < 19 (KITKAT) 的舊版 app，使用 `set()` 應該有精確行為。
但測試中舊版 app 的鬧鐘被當成 inexact 處理，有明顯的 batching 延遲。

## 提示
- 問題出在 `legacyExactLength()` 的 SDK 版本檢查
- KITKAT (API 19) 開始 set() 變成 inexact
- 檢查版本比較的運算符

## 選項
A. `legacyExactLength()` 的 SDK 版本比較使用 `>=` 而非 `<`

B. `legacyExactLength()` 檢查的是 Build.VERSION 而非 targetSdkVersion

C. `legacyExactLength()` 返回的 window 長度計算公式錯誤

D. `legacyExactLength()` 沒有考慮 RTC 和 ELAPSED 類型的差異
