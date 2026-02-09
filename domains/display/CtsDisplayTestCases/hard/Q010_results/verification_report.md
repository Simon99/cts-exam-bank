# Q010 驗證報告

## 基本資訊
- **日期:** 2026-02-09
- **設備:** 2B231FDH200B4Z (Pixel 7)
- **題目:** DisplayInfo Parcel 序列化跨檔案欄位順序錯誤

## Bug 驗證

### 代碼層面 ✅ VERIFIED
Bug 已正確套用到 `DisplayInfo.java`:
```java
// 讀取順序 (readFromParcel, line 564-565):
ownerPackageName = source.readString8();
uniqueId = source.readString8();

// 寫入順序 (writeToParcel, line 629-630) - BUG:
dest.writeString8(uniqueId);          // BUG: should be ownerPackageName
dest.writeString8(ownerPackageName);  // BUG: should be uniqueId
```

順序不一致會導致跨進程 IPC 傳輸時兩個欄位值互換。

### CTS 測試結果 ❌ PROBLEM
```
testPrivateVirtualDisplay: PASSED (202ms)
testPublicPresentationVirtualDisplay: 找不到此測試方法
```

**問題:** 指定的 CTS 測試不會因此 bug 而失敗。

### 原因分析
檢查 `VirtualDisplayTest.java` (line 186-236) 顯示：
- 測試只驗證：
  - VirtualDisplay 創建成功
  - Display flags 正確
  - Surface 匹配
  - 能顯示 presentation
- **未驗證 uniqueId 或 ownerPackageName 的值**

由於 uniqueId 和 ownerPackageName 都是 String 類型，交換後：
- 不會導致 crash
- 不會導致類型錯誤
- 只有依賴這些欄位值的邏輯會出錯

## 結論

| 項目 | 狀態 |
|------|------|
| Patch 套用 | ✅ 成功 |
| 編譯 | ✅ 成功 (37秒) |
| Push 到設備 | ✅ 成功 |
| Bug 代碼驗證 | ✅ 確認存在 |
| CTS 測試失敗 | ❌ 測試通過（未檢測到 bug）|

## 建議

Q010 需要修改，有以下選項：

1. **尋找其他 CTS 測試** - 找到會驗證 uniqueId/ownerPackageName 的測試
2. **修改 meta.json** - 更新為「bug 存在但不會導致 CTS 失敗」
3. **創建自定義驗證腳本** - 使用 dumpsys 驗證跨進程傳輸後的值
4. **降低難度或重新設計** - 選擇更明確可測試的 bug 類型

## 清理狀態
Sandbox-2 需要還原：
```bash
cd ~/develop_claw/aosp-sandbox-2/frameworks/base
git checkout core/java/android/view/DisplayInfo.java
```
