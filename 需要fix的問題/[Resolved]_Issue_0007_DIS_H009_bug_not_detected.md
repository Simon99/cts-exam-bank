# Issue 0007: DIS-H009 Bug 未被偵測

## 基本資訊
- **題目 ID**: DIS-H009 (display/hard/Q009)
- **發現日期**: 2026-02-13
- **嚴重程度**: Medium（題目無效，需重新設計）

## 問題描述

Bug patch 套用後，CTS 測試仍然 PASS，bug 沒有被偵測到。

## Bug Patch 內容

```java
// 在 setter 加入邊界檢查
void setRefreshRateSwitchingTypeInternal(@DisplayManager.SwitchingType int newValue) {
    if (newValue < DisplayManager.SWITCHING_TYPE_NONE
            || newValue > DisplayManager.SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS) {
        newValue = DisplayManager.SWITCHING_TYPE_WITHIN_GROUPS;
    }
    mDisplayModeDirector.setModeSwitchingType(newValue);
}

// 在 getter 映射 ACROSS_AND_WITHIN_GROUPS 到 WITHIN_GROUPS
int getRefreshRateSwitchingTypeInternal() {
    int type = mDisplayModeDirector.getModeSwitchingType();
    if (type == DisplayManager.SWITCHING_TYPE_ACROSS_AND_WITHIN_GROUPS) {
        return DisplayManager.SWITCHING_TYPE_WITHIN_GROUPS;
    }
    return type;
}
```

## CTS 測試結果

```
atest android.display.cts.DisplayTest#testModeSwitchOnPrimaryDisplay

[1/1] testModeSwitchOnPrimaryDisplay: PASSED (9.862s)

All tests passed!
```

## 問題分析

Bug 設計的問題：
- getter 中的映射邏輯會讓 get/set 不一致
- 但 `testModeSwitchOnPrimaryDisplay` 測試沒有驗證 get/set 一致性
- 測試可能只驗證 mode 切換是否成功，不驗證 switching type 的值

## 建議修復方案

### 方案 A：換不同的 CTS 測試
找一個會驗證 `getRefreshRateSwitchingType()` 返回值的測試

### 方案 B：重新設計 Bug
選擇一個能被 `testModeSwitchOnPrimaryDisplay` 偵測的 bug 類型：
- 讓 mode 切換失敗
- 讓切換延遲或超時

## 相關檔案
- Bug Patch: `domains/display/hard/Q009_bug.patch`
- 修改檔案: `DisplayManagerService.java`

## 狀態
- [ ] 待修復
