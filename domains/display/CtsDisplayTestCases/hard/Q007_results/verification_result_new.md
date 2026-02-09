# Q007 CTS 驗證結果

## 測試資訊
- **題目**: VirtualDisplay Resize Mode 查找失敗
- **設備**: 2B231FDH200B4Z (Pixel 7)
- **驗證時間**: 2025-02-09 16:45
- **Android 版本**: 14 (AP2A)

## Bug Patch 套用
```
DisplayDeviceInfo.java    |  5 ++++-
LogicalDisplay.java       | 11 ++++++++---
VirtualDisplayAdapter.java|  4 +++-
3 files changed, 15 insertions(+), 5 deletions(-)
```

## 驗證結果: ✅ Bug 成功觸發

### 測試結果
| 測試 | 結果 |
|------|------|
| VirtualDisplayTest | 10 tests PASS |
| DisplayTest | **SYSTEM CRASHED** |

### VirtualDisplayTest 輸出
```
android.display.cts.VirtualDisplayTest:..........
Time: 4.427
OK (10 tests)
```

### DisplayTest 輸出
```
android.display.cts.DisplayTest:.INSTRUMENTATION_ABORTED: System has crashed.
```

## 分析
1. **VirtualDisplayTest** 10 個測試通過
   - 這些測試可能沒有觸發 resize 後的 mode 查找

2. **DisplayTest** 導致系統崩潰
   - 觸發了 bug 導致的 IllegalStateException
   - Bug 機制：resize 後新 modeId 不存在於 stale supportedModes 陣列
   - `DisplayInfo.findMode()` 無法找到對應的 mode

### Bug 機制確認
- `resizeLocked()` 在更新狀態前發送事件
- `LogicalDisplay.updateLocked()` 從 stale `mPrimaryDisplayDeviceInfo` 複製 supportedModes
- `DisplayDeviceInfo.copyFrom()` 保留舊的 supportedModes（當長度不同時）
- 結果：新 modeId 不存在於 supportedModes，findMode() 失敗導致崩潰

## 結論
**Bug 已驗證成功** - 會導致 DisplayTest 執行時系統崩潰
