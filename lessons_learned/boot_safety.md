# Boot Safety — 哪些修改會導致無法開機

## Bootloop 的類型

| 類型 | 螢幕表現 | 原因 | 恢復方式 |
|------|----------|------|----------|
| Bootloader 層 | fastboot ↔ logo 快速跳動 | kernel/init 崩潰 | 長按 30 秒 → fastboot 重刷 |
| System 層 | 穩定 Google logo | system_server crash loop | 長按 30 秒 → fastboot 重刷 |

**注意**：穩定 Google logo 看起來像卡住，但其實 system_server 在背景不斷重啟。

## 已確認會 Bootloop 的修改

### 1. LogicalDisplay.updateLocked() — mInfo cache 不清除
- **修改內容**：註解掉 `mInfo.set(null)`
- **驗證方式**：Full build + flashall -w
- **結果**：bootloop（確認非增量編譯問題）
- **原因**：`getDisplayInfoLocked()` 回傳 stale cache → WMS 拿到過期 display info → system_server crash loop
- **日期**：2026-02-05

### 2. LogicalDisplay.updateLocked() — supportedModes 截斷
- **修改內容**：截斷 `mBaseDisplayInfo.supportedModes` 陣列
- **結果**：bootloop（理論分析，與 #1 同路徑）
- **原因**：開機時 system_server 讀不到合法的 display mode → 崩潰

## 高風險區域（理論分析，尚未實測）

### DisplayManagerService 核心初始化路徑
- `performTraversalLocked()`
- `configureDisplayLocked()`
- 開機時第一輪 display 配置就會走到，任何異常 = system_server crash

### LocalDisplayAdapter / LocalDisplayDevice
- 開機時第一個被初始化的 display adapter
- 修改 mode 列表、refresh rate、display info 回傳值 → 高風險

### SurfaceFlinger / native 層
- display configuration、HWC 交互
- 改壞 = 黑屏或 native crash loop

### DisplayDeviceInfo 的建構/更新邏輯
- 回傳不合法的值（寬高 0、density 0）→ 所有依賴方崩潰

## 安全區域（已驗證不影響開機）

| 區域 | 驗證題目 | 說明 |
|------|----------|------|
| `Display.java` 客戶端 API | E-Q001 | 只影響 app 端看到的數值 |
| `DisplayManagerService` Binder API 層 | E-Q003, E-Q004 | 只在 app 呼叫時才走到 |
| system property 修改 | E-Q005 | 系統 graceful handle |

## 出題安全規則

1. **Bug 落點只放在 API 層和 client side**
2. **不碰 boot path**（`*Locked()` 開頭的核心方法要先確認是否在開機路徑上）
3. **每題 flash 後先確認能正常開機**，再跑 CTS
4. **Medium/Hard 的跨檔案追蹤可以經過危險區域，但 bug 本身不能在危險區域**
