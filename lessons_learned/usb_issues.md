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
觀察手機螢幕狀態：

| 螢幕狀態 | 情況 | 處理 |
|----------|------|------|
| 穩定 fastboot 畫面 | USB/通訊問題 | 拔插 USB，重試 |
| 穩定 Google logo | system_server crash loop | 長按 30 秒強制關機 → 手動進 fastboot |
| fastboot ↔ logo 跳動 | bootloader 層 bootloop | 長按 30 秒停住 → 進 fastboot |

**注意**：穩定 Google logo 不代表沒事，可能是 system_server 在背景不斷 crash 重啟。

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

## USB 阻塞（D 狀態）- 2026-02-20 更新

### 現象
- `fastboot devices` 顯示設備
- 但任何 fastboot 命令（getvar, flash, reboot）都 hang
- 進程進入 **D 狀態**（不可中斷的 I/O 等待）
- `sudo kill -9` 無效

### 觸發條件
- 連續多次 flash
- 甚至單次 flash 也可能觸發
- **頻率很高，不是偶發**

### 診斷
```bash
# 檢查進程狀態
ps aux | grep fastboot
# 如果 STAT 欄顯示 D，就是 I/O 阻塞

# 測試通訊
timeout 10 fastboot -s <SERIAL> getvar product
# 超時 = 阻塞
```

### 解決方案效果比較
| 方案 | 效果 |
|------|------|
| `sudo kill -9` | ❌ D 狀態無法 kill |
| USB 軟重置（unbind/bind） | ⚠️ 部分恢復 |
| 重啟主機 | ⚠️ 部分恢復 |
| **物理重插 USB 線** | ✅ 最可靠 |
| 長按電源 10 秒 | ✅ 讓設備強制重啟 |

### 預防措施
1. Flash 前做健康檢查（`timeout 10 fastboot getvar`）
2. 每次 flash 後加 2 分鐘冷卻期
3. 使用邏輯等待而非固定秒數
4. 考慮直連主機板 USB（不用 hub）

---

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
