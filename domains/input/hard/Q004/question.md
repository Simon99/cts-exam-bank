# Q004: MotionEvent split() 多點觸控分裂失敗

## CTS Test
`android.view.cts.TouchScreenTest#testSplitMotionEvent`

## Failure Log
```
junit.framework.AssertionFailedError: Split motion event has wrong pointer count
Test scenario: 3 pointers (id: 0, 1, 2), split by mask 0b101 (id 0 and 2)
Expected pointer count: 2
Actual pointer count: 1

Original event:
  Pointer 0: id=0, (100, 200)
  Pointer 1: id=1, (300, 400)
  Pointer 2: id=2, (500, 600)

Split event (mask=0b101):
  Pointer 0: id=0, (100, 200)
  [Missing pointer for id=2]

at android.view.cts.TouchScreenTest.testSplitMotionEvent(TouchScreenTest.java:445)
```

## 現象描述
CTS 測試報告 `MotionEvent.split(int pointerIdBits)` 分裂多點觸控事件時，只包含了第一個符合的指標，遺漏了後續符合遮罩的指標。

## 提示
- `split()` 用於將多點觸控事件拆分給不同的子視圖
- `pointerIdBits` 是位元遮罩，每個 bit 代表一個 pointer ID
- 需要遍歷所有原始指標，檢查其 ID 是否在遮罩中

## 選項

A) `split()` 在找到第一個符合的指標後立即 break，未繼續檢查其他指標

B) `split()` 使用 `==` 比較遮罩而非位元運算 `&`

C) `split()` 計算新 pointerIndex 時未正確遞增，導致後續指標覆蓋前一個

D) `split()` 只檢查了連續的 pointer ID，跳過了不連續的 ID
