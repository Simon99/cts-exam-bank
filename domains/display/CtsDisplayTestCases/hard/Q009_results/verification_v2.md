# Q009 驗證報告 v2

## 基本資訊
- **日期**: 2026-02-09
- **設備**: 2B231FDH200B4Z (Pixel 7)
- **Sandbox**: ~/develop_claw/aosp-sandbox-2
- **驗證人**: Subagent

## Bug 描述
- **Bug 類型**: cross_file_logic_error
- **Bug 描述**: DisplayInfo.equals() 遺漏 rotation 欄位比較，導致旋轉變化時 DisplayManagerGlobal 認為 DisplayInfo 沒有變化，不觸發 onDisplayChanged 回調

## Patch 內容
```diff
--- a/core/java/android/view/DisplayInfo.java
+++ b/core/java/android/view/DisplayInfo.java
@@ -423,7 +423,6 @@ public final class DisplayInfo implements Parcelable {
                 && logicalWidth == other.logicalWidth
                 && logicalHeight == other.logicalHeight
                 && Objects.equals(displayCutout, other.displayCutout)
-                && rotation == other.rotation
                 && modeId == other.modeId
```

## 執行步驟
1. ✅ Patch 成功套用
2. ✅ 編譯 framework-minus-apex 成功 (01:11)
3. ✅ 部署到設備成功 (106 files pushed)
4. ✅ 設備重啟完成
5. ✅ CTS 測試執行成功

## 測試結果
```
Test: android.display.cts.VirtualDisplayTest#testVirtualDisplayRotatesWithContent
Result: PASSED (1.129s)
```

## 驗證結論
**❌ 驗證失敗** - 測試結果與預期不符

| 項目 | 預期 | 實際 |
|------|------|------|
| 測試結果 | FAILED | PASSED |
| Bug 觸發 | onDisplayChanged 不被調用 | onDisplayChanged 被正常調用 |

## 分析

### 為什麼測試沒有失敗？

經過代碼審查，發現 `DisplayManagerGlobal.handleDisplayEventInner()` 中：
```java
if (info != null && (forceUpdate || !info.equals(mDisplayInfo))) {
    mListener.onDisplayChanged(displayId);
}
```

存在 `forceUpdate` 參數，當 `forceUpdate=true` 時會繞過 equals() 檢查。

`handleDisplayChangeFromWindowManager()` 調用時會傳入 `forceUpdate=true`：
```java
handleDisplayEvent(displayId, EVENT_DISPLAY_CHANGED, true /* forceUpdate */);
```

這意味著透過 WindowManager 路徑的 rotation 變化會強制觸發回調，繞過了 equals() 的 bug。

### 結論
這個 bug patch 在 VirtualDisplay rotation 測試場景下**無法被觸發**，因為系統有 forceUpdate 機制作為備援。

### 建議
1. 這個題目可能需要尋找其他測試來驗證
2. 或者需要修改 meta.json 中的 targetTests
3. 可能需要找一個純粹依賴 equals() 比較的測試場景

## 日誌位置
- Atest logs: `/tmp/atest_result_simon/20260209_113156_oqb43iff/log`
- Test output: `/tmp/q009_test_output.txt`
