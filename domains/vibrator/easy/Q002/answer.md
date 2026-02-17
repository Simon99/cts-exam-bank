# Q002 Answer: Amplitude Control Support Check Failed

## 正確答案
**C**

## 問題根因
在 `Vibrator.java` 的 `hasAmplitudeControl()` 函數中，
回傳值被硬編碼為 `true`，而不是從 `VibratorInfo` 取得實際的硬體能力。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public boolean hasAmplitudeControl() {
    return true;  // BUG: 硬編碼，忽略實際硬體能力
}

// 正確的代碼
public boolean hasAmplitudeControl() {
    return getInfo().hasAmplitudeControl();
}
```

## 選項分析
- **A** VibratorInfo 初始化失敗 — 錯誤，會導致 crash 而非錯誤回傳值
- **B** 權限不足導致查詢失敗 — 錯誤，此 API 不需要特殊權限
- **C** 回傳值被硬編碼為 true — ✅ 正確
- **D** HAL 版本不相容 — 錯誤，HAL 問題會有其他錯誤訊息

## 相關知識
- 振幅控制允許調整振動強度（0-255）
- 不是所有振動器硬體都支援振幅控制
- 應用程式應先檢查此能力再使用變化振幅

## 難度說明
**Easy** - 硬編碼回傳值是常見的調試殘留，檢查函數實作即可發現。
