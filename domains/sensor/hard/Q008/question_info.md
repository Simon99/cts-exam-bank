# sensor_hard_Q008

## 基本資訊
- **ID**: SEN-H008
- **標題**: unregisterListenerImpl Fails to Stop HAL When Removing Last Sensor
- **CTS 測試**: `android.hardware.cts.SensorTest#testUnregisterStopsHal`

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: 🔄 待重驗

## 問題簡述
涉及 unregister, cleanup, hal
