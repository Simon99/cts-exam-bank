# M-Q002: Display Mode 比較異常

## 問題描述

你收到一份 CTS 測試報告，顯示 `CtsDisplayTestCases` 有 2 個測試失敗：

```
=============== Summary ===============
2/2 modules completed
PASSED            : 94
FAILED            : 2
```

失敗的測試是 `testRefreshRateSwitchOnSecondaryDisplay`，錯誤訊息很奇怪：

```
java.lang.AssertionError: 
expected: android.view.Display$Mode<{id=224, width=182, height=162, fps=90.0...}>
 but was: android.view.Display$Mode<{id=224, width=182, height=162, fps=90.0...}>
```

**兩個 Mode 的 toString() 輸出完全一樣，但 assertEquals() 卻失敗了！**

## 重現步驟

```bash
export USE_ATS=false
./tools/cts-tradefed run cts -m CtsDisplayTestCases -s <device_serial>
```

## 任務

1. 分析為什麼看起來相同的 Mode 會比較失敗
2. 找出 bug 的位置
3. 提供修復方案

## 提示

- toString() 和 equals() 是兩個不同的方法
- Mode.equals() 內部使用了 matches() 方法
- 注意參數順序

## 難度

Medium（需要理解 equals/toString/matches 之間的關係）

## 時間限制

25 分鐘
