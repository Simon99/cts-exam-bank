# Q005: F2FS Superblock 驗證邏輯錯誤

## 問題描述

CTS 測試 `RandomRWTest` 失敗，設備在使用 F2FS 檔案系統的存儲卷上報告超級塊無效，導致隨機讀寫測試無法執行。

## 失敗的 CTS 測試

```
Module: CtsFileSystemTestCases
Test: android.filesystem.cts.RandomRWTest
```

## 錯誤訊息

```
android.filesystem.cts.RandomRWTest > testRandomRead FAILED
    java.lang.RuntimeException: Unable to mount filesystem
    Caused by: fs_mgr error - Invalid f2fs superblock
```

## 相關日誌

```
I fs_mgr : read_f2fs_superblock: checking /dev/block/sda17
I fs_mgr : Invalid f2fs superblock on '/dev/block/sda17'
E fs_mgr : fs_stat: /dev/block/sda17 FS_STAT_INVALID_MAGIC
W Vold   : Failed to prepare_fs_for_mount for f2fs volume
```

## 背景知識

F2FS 檔案系統設計有冗餘超級塊機制：
- **superblock1**: 位於固定偏移 F2FS_SUPER_OFFSET
- **superblock2**: 位於 pagesize + F2FS_SUPER_OFFSET

設計意圖是任一超級塊有效即可繼續掛載，提供容錯能力。

## 提示

1. 查看 `fs_mgr.cpp` 中的 `read_f2fs_superblock()` 函數
2. 分析超級塊有效性判斷的條件邏輯
3. 思考冗餘設計的語義：「兩個都無效」vs「任一個無效」

## 選項

A. `pread()` 讀取的偏移量計算錯誤，導致讀取到錯誤位置  
B. `cpu_to_le32()` 位元組序轉換方向錯誤  
C. 超級塊有效性判斷使用 `||` 而非 `&&`，邏輯過於嚴格  
D. `F2FS_SUPER_MAGIC` 常數值定義錯誤

## 難度評估

- **時間:** 20 分鐘
- **複雜度:** 中等（需要理解 F2FS 冗餘超級塊設計）
