# Q005 Answer: Predefined Effect Creation Failed

## 正確答案
**B**

## 問題根因
在 `PrebakedSegment.java` 的 `validate()` 方法中，
效果 ID 的驗證 switch 缺少 `EFFECT_CLICK` 的 case，
導致 EFFECT_CLICK (ID=0) 落入 default 分支而被錯誤拒絕。

## Bug 位置
`frameworks/base/core/java/android/os/vibrator/PrebakedSegment.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼（缺少 EFFECT_CLICK case）
public void validate() {
    switch (mEffectId) {
        // case VibrationEffect.EFFECT_CLICK:  <-- 被移除！
        case VibrationEffect.EFFECT_DOUBLE_CLICK:
        case VibrationEffect.EFFECT_HEAVY_CLICK:
        case VibrationEffect.EFFECT_POP:
        case VibrationEffect.EFFECT_TEXTURE_TICK:
        case VibrationEffect.EFFECT_THUD:
        case VibrationEffect.EFFECT_TICK:
            break;
        default:
            // EFFECT_CLICK 落入這裡，驗證失敗！
            throw new IllegalArgumentException("Unknown prebaked effect type...");
    }
}

// 正確的代碼
public void validate() {
    switch (mEffectId) {
        case VibrationEffect.EFFECT_CLICK:      // ✅ 必須包含
        case VibrationEffect.EFFECT_DOUBLE_CLICK:
        case VibrationEffect.EFFECT_HEAVY_CLICK:
        ...
            break;
    }
}
```

## 選項分析
- **A** EFFECT_CLICK 常數值定義錯誤 — 錯誤，常數定義是正確的
- **B** 驗證邏輯缺少 EFFECT_CLICK case — ✅ 正確，ID=0 未被處理
- **C** Prebaked 類別建構失敗 — 錯誤，異常在驗證階段就拋出
- **D** 系統不支援預定義效果 — 錯誤，會有不同的錯誤訊息

## 相關知識
- 預定義效果 ID 從 0 開始（EFFECT_CLICK = 0）
- `validate()` 使用 switch-case 驗證合法的效果 ID
- 漏掉 case 是常見的維護疏漏

## 難度說明
**Easy** - 錯誤訊息明確指出效果類型問題，追蹤 validate() 邏輯即可發現缺失的 case。
