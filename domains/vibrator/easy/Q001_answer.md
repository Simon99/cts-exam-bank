# Q001 Answer: Vibrator Availability Check Failed

## 正確答案
**B**

## 問題根因
在 `Vibrator.java` 的 `hasVibrator()` 函數中，判斷邏輯被錯誤地反轉。
原本應該檢查 `getInfo().getId() != -1` 來確認振動器存在，
但 bug 將 `!=` 寫成 `==`，導致只有不存在振動器時才回傳 true。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public boolean hasVibrator() {
    return getInfo().getId() == -1;  // BUG: 邏輯反轉
}

// 正確的代碼
public boolean hasVibrator() {
    return getInfo().getId() != -1;
}
```

## 選項分析
- **A** `getInfo()` 回傳 null — 錯誤，getInfo() 有非空保證
- **B** ID 比較運算符錯誤 — ✅ 正確，`==` 應為 `!=`
- **C** 權限檢查失敗 — 錯誤，hasVibrator() 不需要特殊權限
- **D** 硬體抽象層未載入 — 錯誤，HAL 問題會導致 crash，不是簡單的 false

## 相關知識
- Vibrator ID 為 -1 表示不存在振動器
- `VibratorInfo` 封裝了振動器的硬體能力資訊
- hasVibrator() 是判斷振動功能可用性的基礎 API

## 難度說明
**Easy** - 從 fail log 可直接看出是布林值錯誤，只需在源碼中找到比較運算符即可。
