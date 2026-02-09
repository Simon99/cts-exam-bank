# Q010 答案

## Bug 位置

**檔案:** `frameworks/base/core/java/android/view/DisplayInfo.java`
**方法:** `writeToParcel(Parcel, int)`
**行號:** 608-609 行

## Bug 描述

`DisplayInfo.writeToParcel()` 方法中 `defaultModeId` 和 `userPreferredModeId` 的寫入順序與 `readFromParcel()` 的讀取順序不一致，導致跨進程 IPC 傳輸後兩個欄位的值被互換。

## readFromParcel 順序（正確）

```java
// 約 541-542 行
defaultModeId = source.readInt();      // 先讀 defaultModeId
userPreferredModeId = source.readInt(); // 再讀 userPreferredModeId
```

## writeToParcel 原始代碼（正確）

```java
// 約 608-609 行
dest.writeInt(defaultModeId);           // 先寫 defaultModeId
dest.writeInt(userPreferredModeId);     // 再寫 userPreferredModeId
```

## writeToParcel Bug 代碼

```java
// 約 608-609 行 (Bug)
dest.writeInt(userPreferredModeId);     // 錯誤：應該先寫 defaultModeId
dest.writeInt(defaultModeId);           // 錯誤：應該後寫 userPreferredModeId
```

## 修復方法

恢復正確的寫入順序：
```java
dest.writeInt(defaultModeId);
dest.writeInt(userPreferredModeId);
```

## Bug 觸發機制

1. 應用調用 `display.setUserPreferredDisplayMode(newMode)`
2. DisplayManagerService 設置 `userPreferredModeId = newMode.getModeId()`
3. 應用透過 Binder IPC 獲取 DisplayInfo（調用 `getUserPreferredDisplayMode()`）
4. DisplayManagerService 調用 `displayInfo.writeToParcel()` 序列化資料
5. 由於順序錯誤：
   - `userPreferredModeId` 被寫入 `defaultModeId` 的位置
   - `defaultModeId` 被寫入 `userPreferredModeId` 的位置
6. 應用端調用 `readFromParcel()` 反序列化
7. 因為讀取順序不變：
   - `defaultModeId` 讀取到的是 `userPreferredModeId` 的值
   - `userPreferredModeId` 讀取到的是 `defaultModeId` 的值
8. `getUserPreferredDisplayMode()` 返回錯誤的 mode
9. 測試 assertion 失敗

## 為什麼只有跨進程時出問題？

同進程內，直接訪問 DisplayInfo 物件的欄位不需要 Parcel 序列化：
```java
// 同進程
displayInfo.userPreferredModeId  // 直接訪問，正確

// 跨進程 (透過 Binder IPC)
DisplayInfo info = getDisplayInfo();  // 經過序列化/反序列化
info.userPreferredModeId  // 因為順序錯誤，值被交換，錯誤
```

## Parcelable 序列化原理

```
Parcel 是一個線性 buffer：
| field1 | field2 | field3 | ... |

writeToParcel 寫入順序決定 buffer 內容：
| defaultModeId | userPreferredModeId | ... |  (正確)
| userPreferredModeId | defaultModeId | ... |  (Bug)

readFromParcel 按固定順序讀取：
defaultModeId = source.readInt();       // 讀位置 0
userPreferredModeId = source.readInt(); // 讀位置 1

如果寫入順序錯誤，讀取結果就會錯誤。
```

## 學習要點

1. Parcelable 的 writeToParcel 和 readFromParcel 欄位順序必須完全一致
2. 這類 bug 只在跨進程 IPC 場景出現，同進程不受影響
3. 相同類型的相鄰欄位交換不會導致 crash，只會導致邏輯錯誤
4. 這類 bug 很難發現，需要仔細比對兩個方法的欄位順序
