# Q007 Answer: Vibrate With VibrationAttributes Usage Ignored

## 正確答案
**A**

## 問題根因
在 `SystemVibrator.java` 的 `vibrate()` 方法中，
忽略了傳入的 `attributes` 參數，使用了預設的空 VibrationAttributes。

## Bug 位置
`frameworks/base/core/java/android/os/SystemVibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
@Override
public void vibrate(int uid, String opPkg, VibrationEffect effect,
        String reason, VibrationAttributes attributes) {
    // BUG: 忽略 attributes 參數，使用預設值
    mService.vibrate(uid, opPkg, effect, reason, 
            new VibrationAttributes.Builder().build());
}

// 正確的代碼
@Override
public void vibrate(int uid, String opPkg, VibrationEffect effect,
        String reason, VibrationAttributes attributes) {
    mService.vibrate(uid, opPkg, effect, reason, attributes);
}
```

## 選項分析
- **A** attributes 參數被忽略，使用預設值 — ✅ 正確
- **B** VibrationAttributes 序列化失敗 — 錯誤，會有 Parcel 異常
- **C** Service 端不支援 usage — 錯誤，Service 有正確處理
- **D** USAGE_ALARM 常數值錯誤 — 錯誤，常數定義正確

## 相關知識
- VibrationAttributes 包含 usage（用途）和 flags
- 不同 usage 有不同的音量和權限規則
- USAGE_ALARM = 17 用於鬧鐘振動

## 難度說明
**Medium** - 需要追蹤參數從 API 到 Service 的傳遞路徑。
