# DIS-M005 CTS 驗證結果

**驗證日期**: 2026-02-17 17:18-17:20 GMT+8
**設備**: 27161FDH20031X (Pixel 7)
**CTS 版本**: 14_r7

## 測試結果摘要

| Module | Pass | Fail | Total |
|--------|------|------|-------|
| CtsDisplayTestCases | 1 | 4 | 5 |
| CtsDisplayTestCases[instant] | 1 | 4 | 5 |

## 驗證結論

✅ **PASS** - Bug 注入成功觸發預期的測試失敗

### 失敗的測試（預期）
- `testHdrApiMethods`
- `testGetHdrCapabilitiesWithUserDisabledFormats`
- `testUntrustedSysDecorVirtualDisplay`
- `testVirtualDisplayWithRequestedRefreshRate`

### 通過的測試
- `testTrustedVirtualDisplay`

## 檔案清單

- `test_result.xml` - CTS 完整測試報告（XML）
- `test_result.html` - CTS 測試報告（HTML 可視化）
- `invocation_summary.txt` - 執行摘要
- `device-info-files/` - 設備資訊
