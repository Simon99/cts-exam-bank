# Issue List — 問題追蹤

簡要記錄每個遇到的問題現象，方便回查。詳細分析見各分類 .md 檔案。

## 開放中

| # | 現象 | 分類 | 狀態 |
|---|------|------|------|
| I-005 | `PRODUCT_DEFAULT_PROPERTY_OVERRIDES` 寫入 mk 但 `getprop` 看不到 | build_deploy | 待查（workaround: 直接寫 build.prop） |
| I-006 | AOSP 缺 `BRIGHTNESS_SLIDER_USAGE` 權限，brightness tracking 測試全 SKIP | cts_testing | 避開（不出相關題目） |
| I-007 | MctsMediaV2 的 5/6 題需要重新單獨驗證（之前多 patch 同時 apply 互相干擾） | cts_testing | 待驗證 |

## 已解決

| # | 現象 | 分類 | 解法 |
|---|------|------|------|
| I-001 | CTS 跑完後 fastboot/adb 操作 hang | usb_issues | `pkill -f "ats_console_deploy\|olc_server"` |
| I-002 | `fastboot devices` 列出裝置但所有命令 hang | usb_issues | 長按電源 30 秒 → 拔插 USB → 重進 fastboot |
| I-003 | `m services` + `make systemimage` 後 flash → bootloop | build_deploy | 一律用 `make -j$(nproc)` full build |
| I-004 | `LogicalDisplay.updateLocked()` 修改 → bootloop | boot_safety | 不碰核心更新邏輯，bug 只放 API 層 |
