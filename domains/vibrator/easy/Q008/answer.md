# Q008 Answer: Get Vibrator Info Returns Null

## 正確答案
**B**

## 問題根因
在 `Vibrator.java` 的 `getInfo()` 方法中，當快取為空時錯誤地回傳 null，
而非建立新的 VibratorInfo 物件或回傳預設值。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public VibratorInfo getInfo() {
    if (mVibratorInfo == null) {
        return null;  // BUG: 應該初始化而非回傳 null
    }
    return mVibratorInfo;
}

// 正確的代碼
public VibratorInfo getInfo() {
    if (mVibratorInfo == null) {
        mVibratorInfo = VibratorInfo.EMPTY_VIBRATOR_INFO;
    }
    return mVibratorInfo;
}
```

## 選項分析
- **A** 權限不足導致查詢失敗 — 錯誤，getInfo() 不需要權限
- **B** 快取為空時回傳 null 而非初始化 — ✅ 正確
- **C** VibratorInfo 類別載入失敗 — 錯誤，會有 ClassNotFoundException
- **D** 硬體驅動未載入 — 錯誤，仍應回傳空的 VibratorInfo

## 相關知識
- VibratorInfo 包含振動器 ID、能力等資訊
- EMPTY_VIBRATOR_INFO 是預設的空物件
- API 設計要求非空回傳值以避免呼叫端的 NPE

## 難度說明
**Easy** - NPE 明確指向 null 回傳值，檢查 getInfo() 的 null 處理即可。
