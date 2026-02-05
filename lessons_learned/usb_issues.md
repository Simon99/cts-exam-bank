# USB & Fastboot — 連線問題排除

## fastboot devices 能列出 ≠ 能通訊

### 現象
- `fastboot devices` 顯示裝置
- 但 `fastboot getvar product`、`fastboot flash` 等操作全部 hang

### 可能原因

**原因 A：Bootloop 導致 fastboot 視窗過短（較常見）**
- 手機在 bootloop 循環：fastboot → 嘗試開機 → 失敗 → 回 fastboot
- `fastboot devices` 剛好抓到 fastboot 瞬間
- 但執行 flash 時，手機已經跳到「嘗試開機」階段
- **診斷**：觀察手機螢幕是否在 fastboot 和 Google logo 之間跳動
- **解法**：長按電源 30 秒強制關機，讓它停在 fastboot 不繼續嘗試

**原因 B：USB 狀態異常**
- flash 操作中途被中斷
- CTS 殘留進程佔用（較少見，通常是影響 adb 不是 fastboot）
- **診斷**：手機螢幕穩定在 fastboot，但命令 hang
- **解法**：拔插 USB、換 USB 口

### 診斷步驟
1. **先看手機螢幕**：是穩定 fastboot 還是在跳動（bootloop）
2. 如果跳動 → 原因 A（bootloop）
3. 如果穩定 → 原因 B（USB 狀態）

### 解決方法（通用）
1. **長按電源鍵 30 秒**（不是短按！）強制關機
2. **拔 USB 線**，等 5 秒
3. **重新插 USB**
4. **同時按住 電源 + 音量下** 進 fastboot
5. 驗證：`fastboot getvar product` 必須秒回

### Bootloop 時搶 fastboot 視窗
```bash
# 持續嘗試，趁 fastboot 視窗連上
while ! fastboot getvar product 2>/dev/null; do sleep 0.5; done
fastboot flash ...
```

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
