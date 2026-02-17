# Q001: OBB 掛載回調異常

## 問題描述

CTS 測試 `testMountAndUnmountObbNormal` 失敗，測試嘗試掛載一個 OBB 檔案並驗證回調狀態。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testMountAndUnmountObbNormal
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Expected mount state 1, but got 20
    at android.os.storage.cts.StorageManagerTest.testMountAndUnmountObbNormal
```

## 相關日誌

```
D StorageManagerService: handleObbMount: Mounting OBB /data/local/tmp/test.obb
D StorageManagerService: OBB mount completed successfully
D StorageManagerService: Notifying state change: state=20
W StorageManagerTest: Unexpected callback state: expected MOUNTED(1), got 20
```

## 提示

1. 追蹤 `notifyStateChange()` 方法的調用鏈
2. 檢查狀態碼常量的定義
3. 注意可能存在多個相關的問題點

## 影響範圍

- OBB 掛載/卸載功能
- 依賴 OBB 狀態回調的應用程式

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要追蹤跨檔案的數據流）
