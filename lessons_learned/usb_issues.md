# USB & Fastboot — 連線問題排除

## fastboot devices 能列出 ≠ 能通訊

### 現象
- `fastboot devices` 顯示裝置
- 但 `fastboot getvar product`、`fastboot flash` 等操作全部 hang

### 原因
USB enumeration 成功但 protocol 通訊異常。常見觸發條件：
1. CTS tradefed 殘留進程佔用 USB
2. flash 操作中途被中斷
3. 裝置在異常狀態（bootloop 中）的 USB re-enumeration

### 解決方法
1. **長按電源鍵 30 秒**（不是短按！）強制關機
2. **拔 USB 線**，等 5 秒
3. **重新插 USB**
4. **同時按住 電源 + 音量下** 進 fastboot
5. 驗證：`fastboot getvar product` 必須秒回

### 注意
- 換 USB 口前先確認新口有 data 功能
- 某些 USB 口只有供電沒有 data

## CTS 殘留進程搶佔 USB

### 現象
- 跑完 CTS 後 fastboot/adb 操作異常
- `ps aux | grep tradefed` 可以看到殘留進程

### 解決方法
```bash
# CTS 測試後必做清理
pkill -f "ats_console_deploy\|olc_server"
```

### 說明
tradefed 的 OLC server 不會自動退出，會持續佔用 USB 通道。
每次 CTS 測試後都要清理。

## Bootloop ≠ 磚

### 現象
- 手機卡在 Google logo 不斷重啟

### 說明
- 如果 flash 從未成功完成，手機上還是原來的 image
- bootloop 可能只是 USB 狀態異常 + 殘留進程的組合效果
- 進 fastboot 重新 flash 即可恢復
