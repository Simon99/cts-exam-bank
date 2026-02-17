# AlarmManager_hard_Q002

## 基本資訊
- **ID**: ALM-H002
- **標題**: triggerAlarmsLocked ConcurrentModification
- **CTS 測試**: `android.alarmmanager.cts.BasicApiTests#testRapidAlarmFiring`

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: 🔄 待重驗

## 問題簡述
涉及 ConcurrentModificationException, iteration, callback
