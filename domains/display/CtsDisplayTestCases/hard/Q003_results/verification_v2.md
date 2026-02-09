# Q003 驗證結果 v2

## 基本資訊
- **題目 ID:** display-hard-003
- **驗證日期:** 2025-02-09
- **設備:** 2B231FDH200B4Z (Pixel 7)
- **Sandbox:** ~/develop_claw/aosp-sandbox-2

## 測試結果
| 項目 | 結果 |
|------|------|
| Patch 套用 | ✅ 成功 |
| 編譯 (services) | ✅ 成功 (01:01) |
| 部署 | ✅ 成功 |
| 設備開機 | ✅ 正常 |
| CTS 測試 | ❌ **失敗** (預期結果) |

## 驗證狀態
**✅ 驗證成功** - Bug patch 成功導致測試失敗

## 測試輸出

```
INSTRUMENTATION_STATUS: stack=java.lang.AssertionError: expected:<60.0> but was:<30.0>
	at org.junit.Assert.fail(Assert.java:89)
	at org.junit.Assert.failNotEquals(Assert.java:835)
	at org.junit.Assert.assertEquals(Assert.java:577)
	at org.junit.Assert.assertEquals(Assert.java:701)
	at android.display.cts.VirtualDisplayTest.testVirtualDisplayWithRequestedRefreshRate(VirtualDisplayTest.java:331)

FAILURES!!!
Tests run: 1,  Failures: 1
```

## 錯誤訊息分析

**預期 (meta.json):** `expected:<30.0> but was:<60.0>`
**實際輸出:** `expected:<60.0> but was:<30.0>`

### 差異原因
CTS 測試代碼中 `assertEquals(display.getRefreshRate(), REQUESTED_REFRESH_RATE, 0.1f)` 的參數順序
JUnit 規範是 `assertEquals(expected, actual, delta)`，但測試代碼將 actual (display.getRefreshRate()) 放在了第一個位置

### 關鍵確認
- **Bug 生效:** ✅ display.getRefreshRate() 返回 60.0 (而非請求的 30.0)
- **測試失敗:** ✅ AssertionError 表示 refresh rate 不符預期
- **數值正確:** ✅ 60.0 vs 30.0 符合 bug 設計

## Bug 說明
- **位置:** `VirtualDisplayAdapter.java:572`
- **方法:** `VirtualDisplayDevice.getRefreshRate()`
- **問題:** 忽略 `mRequestedRefreshRate`，總是返回固定的 `REFRESH_RATE` (60Hz)

## 重要發現
⚠️ **編譯 target 注意事項:**
- `VirtualDisplayAdapter.java` 在 `services/core/` 目錄
- 需要編譯 `m services` 而非 `m framework-minus-apex`
- `framework-minus-apex` 不會包含 services 目錄的修改

## 建議更新 meta.json
1. 更新 `expectedResult.errorMessage` 以匹配實際輸出順序
2. 標記為已驗證
