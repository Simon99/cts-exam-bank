# Q009 Answer: VelocityTracker obtain() 失敗

## 正確答案
**C) `obtain()` 中直接回傳 null**

## 問題根因
在 `VelocityTracker.java` 的 `obtain()` 靜態方法中，
沒有實際從物件池取得或建立新的 VelocityTracker，而是直接回傳 null。

## Bug 位置
`frameworks/base/core/java/android/view/VelocityTracker.java`

## 修復方式
```java
// 錯誤的代碼
public static VelocityTracker obtain() {
    return null;  // BUG: 直接回傳 null
}

// 正確的代碼
public static VelocityTracker obtain() {
    VelocityTracker instance = sPool.acquire();
    return (instance != null) ? instance : new VelocityTracker(null);
}
```

## 為什麼其他選項不對

**A)** 鎖的問題會導致死鎖或競爭條件，不會直接回傳 null。

**B)** 物件池為空時回傳 null 是可能的 bug，但正確實作會在池空時建立新物件。
這個選項比較合理，但從 log 看是每次都 null，所以是直接回傳 null。

**D)** 建構子失敗通常會拋出異常，不會回傳 null。

## 相關知識
- Android 的物件池 (Object Pool) 設計模式
- VelocityTracker 用於計算觸控手勢的速度
- obtain() 和 recycle() 配對使用

## 難度說明
**Easy** - NPE 和 null 回傳值是直接對應的，檢查 obtain() 即可。
