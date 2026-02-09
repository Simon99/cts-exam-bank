# Q010 提示

## 提示 1 - 入門
問題與 Parcelable 序列化有關。

當 DisplayInfo 透過 Binder IPC 傳輸時：
1. 發送端調用 `writeToParcel()` 將資料寫入 Parcel
2. 接收端調用 `readFromParcel()` 從 Parcel 讀取資料

這兩個方法的欄位順序必須完全一致。

---

## 提示 2 - 進階
測試顯示 `getUserPreferredDisplayMode()` 返回錯誤的值。

相關欄位包括：
- `defaultModeId` - 預設 mode 的 ID
- `userPreferredModeId` - 用戶偏好 mode 的 ID

這兩個欄位都是 `int` 類型，在 Parcel 中相鄰。

---

## 提示 3 - 關鍵
比較 `writeToParcel()` 和 `readFromParcel()` 中這兩個欄位的順序：

```java
// readFromParcel() 順序：
defaultModeId = source.readInt();      // 先讀
userPreferredModeId = source.readInt(); // 後讀

// writeToParcel() 順序應該是？
dest.writeInt(defaultModeId);           // 應該先寫
dest.writeInt(userPreferredModeId);     // 應該後寫
```

如果 writeToParcel 中順序相反，讀取時兩個值會互換。

---

## 提示 4 - 答案方向
檢查 `DisplayInfo.writeToParcel()` 方法（大約在第 605-610 行）。

Bug 是 defaultModeId 和 userPreferredModeId 的寫入順序被交換了：
```java
// 錯誤代碼
dest.writeInt(userPreferredModeId);  // 應該是 defaultModeId
dest.writeInt(defaultModeId);        // 應該是 userPreferredModeId
```

修復方法是恢復正確的順序。
