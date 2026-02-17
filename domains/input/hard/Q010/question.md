# Q010: MotionEvent recycle() 後使用導致數據損壞

## CTS Test
`android.view.cts.TouchScreenTest#testRecyclePoolCorruption`

## Failure Log
```
junit.framework.AssertionFailedError: Recycled event data appears in new event
Test scenario:
  1. event1 = MotionEvent.obtain() at (100, 200)
  2. event1.recycle()
  3. event2 = MotionEvent.obtain() at (300, 400)
  4. Access event1.getX() after recycle (illegal but possible)
  5. Check event2 coordinates

event1.getX() after recycle: 300.0 (shows event2's data!)
event2.getX(): 300.0 (correct)
event2.getY(): 200.0 (WRONG - shows event1's partial data!)

Expected event2.getY(): 400.0

Memory corruption: pool reuse without proper field clearing.

at android.view.cts.TouchScreenTest.testRecyclePoolCorruption(TouchScreenTest.java:678)
```

## 現象描述
CTS 測試發現 `MotionEvent.recycle()` 回收後，從物件池再次取得的事件包含之前事件的殘留數據。新事件的 Y 座標顯示舊事件的值。

## 提示
- `obtain()` 從物件池取得已回收的事件物件
- 物件池重用需要完整清除或重新初始化所有欄位
- 如果只設定部分欄位，其他欄位會保留舊值

## 選項

A) `obtain()` 未清除從池中取出的事件的所有欄位，只更新了 X 座標

B) `recycle()` 未將事件加入池中，導致下次 obtain 取得相同物件時欄位未更新

C) 物件池使用 WeakReference，GC 後物件被部分回收導致數據不一致

D) `obtain()` 的初始化順序錯誤，Y 座標的設定被後續操作覆蓋
