# Framework Patch 設計經驗（Q002/Q003 教訓）

**版本：** 1.0
**更新時間：** 2026-02-24

## 核心原則

**Bug patch 必須「精準打擊」：讓 CTS 測試失敗，但不影響系統正常啟動。**

## Q002 教訓

### 第一版 patch（失敗）

```java
// BaseBundle.deepCopy() 直接返回 null
public Bundle deepCopy() {
    return null;  // 太激進！
}
```

**問題：**
- WiFi 無法啟動
- `sys.boot_completed` 永遠不會設定
- 系統服務依賴 Bundle 傳遞配置，直接返回 null 導致連鎖崩潰

### 第二版 patch（成功）

```java
// 只在嵌套 Bundle 的 deep copy 時返回 null
if (value instanceof Bundle) {
    return null;  // 精準打擊特定路徑
}
```

**為什麼成功：**
- 只影響 `Bundle.deepCopy()` 中對嵌套 Bundle 的處理
- 系統啟動時的 Bundle 操作不走這個路徑
- CTS 測試 `testDeepCopy` 會精確觸發這個 bug

## Q003 教訓

### 失敗的 patch

```java
// Intent 序列化時跳過 mContentUserHint
// out.writeInt(mContentUserHint);  // 註解掉
```

**問題：**
- Intent 是 Android 最核心的 IPC 機制
- 系統啟動時大量使用 Intent 傳遞
- 序列化不完整導致 Intent 解析失敗 → 系統服務崩潰

### 如何修正

**方向 1：只在特定條件下觸發**
```java
// 只有特定 flag 時才跳過序列化
if ((mFlags & FLAG_SPECIFIC_TEST) != 0) {
    // 不寫 mContentUserHint
} else {
    out.writeInt(mContentUserHint);
}
```

**方向 2：寫入錯誤值而非跳過**
```java
// 寫入錯誤值，而非不寫
out.writeInt(mContentUserHint + 1);  // 偏移導致值錯誤
```

**方向 3：選擇影響範圍更小的欄位**
- 避免觸及 Intent 的核心序列化邏輯
- 找 CTS 專門測試但系統啟動不依賴的欄位

## Patch 設計檢查清單

在提交 patch 前，確認：

- [ ] 系統能正常啟動（`sys.boot_completed = 1`）
- [ ] WiFi 能連接
- [ ] ADB 能正常使用
- [ ] 只有目標 CTS 測試會失敗
- [ ] 其他 CTS 測試不受影響

## 測試流程建議

1. **先 local 測試**：用 emulator 或備用設備確認系統能啟動
2. **觀察 logcat**：看有沒有關鍵服務崩潰
3. **確認 WiFi**：CTS 需要網路連接
4. **再跑真機驗證**

---

*記錄人：薩吉（四號）*
*日期：2026-02-24*
