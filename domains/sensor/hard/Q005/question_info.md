# sensor_hard_Q005

## 基本資訊
- **ID**: SEN-H005
- **標題**: flushImpl Deadlock Under Heavy Load
- **CTS 測試**: `android.hardware.cts.SensorBatchingFifoTest#testFlushUnderLoad`

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: 🔄 待重驗

## 問題簡述
涉及 deadlock, synchronization, lock-order
