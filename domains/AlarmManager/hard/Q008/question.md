# Q008: reorderAlarmsBasedOnStandbyBuckets Priority Inversion

## CTS Test
`android.alarmmanager.cts.AppStandbyTests#testBucketPriority`

## Failure Log
```
junit.framework.AssertionFailedError: Bucket priority not respected
expected: ACTIVE app alarm fires before RARE app alarm
actual: RARE app alarm fired first

at android.alarmmanager.cts.AppStandbyTests.testBucketPriority(AppStandbyTests.java:423)
```

## 現象描述
兩個 app 設定了相同時間的鬧鐘：一個是 ACTIVE bucket，一個是 RARE bucket。
ACTIVE 應該優先觸發，但實際上 RARE bucket 的鬧鐘先觸發了。

## 提示
- 問題出在 `reorderAlarmsBasedOnStandbyBuckets()` 的排序邏輯
- Bucket 優先級排序影響鬧鐘觸發順序
- 檢查 Comparator 的實作

## 選項
A. Comparator 的比較結果返回值正負號錯誤，導致排序順序相反

B. 排序只對單一 batch 內生效，沒有跨 batch 重排

C. 排序使用了不穩定排序算法，導致隨機順序

D. bucket 值的映射表定義錯誤，RARE 的數值比 ACTIVE 小
